#include "TOTVS.CH"
#Include "RWMAKE.CH"
#Include "RESTFUL.CH"

WSRESTFUL WSClient DESCRIPTION "Clientes API" FORMAT APPLICATION_JSON
	WSDATA page					AS INTEGER	OPTIONAL
	WSDATA pageSize 			AS INTEGER	OPTIONAL
	WSDATA searchKey 			AS STRING	OPTIONAL
	WSDATA branch				AS STRING 	OPTIONAL
	WSDATA byId					AS BOOLEAN	OPTIONAL

WSMETHOD GET customers DESCRIPTION 'Lista de Clientes' WSSYNTAX '/api/v1/WSClient' PATH '/api/v1/WSClient' PRODUCES APPLICATION_JSON  

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET / cliente
Retorna a lista de clientes disponíveis.
@param	SearchKey		, String, chave de pesquisa utilizada em diversos campos
		Page			, Numeric, numero da pagina
		PageSize		, Numeric, quantidade de registros por pagina
		byId			, Logical, indica se deve filtrar apenas pelo codigo
@return cResponse		, String, JSON contendo a lista de clientes
@author	Lucas Silva Vieira
@since		03/08/2021
@version	12.1.27
/*/
//-------------------------------------------------------------------
WSMETHOD GET customers WSRECEIVE searchKey, page, pageSize, branch WSREST WSClient
	Local lRet:= .T.
	lRet := Customers( self )
Return( lRet )
Static Function Customers( oSelf )
	Local aListCli		:= {}
	Local cJsonCli		:= ''
	Local oJsonCli		:= JsonObject():New()
	Local cSearch		:= ''
	Local cWhere		:= "AND SA1.A1_FILIAL = '"+xFilial('SA1')+"'"
	Local nCount		:= 0
	Local nStart 		:= 1
	Local nReg 			:= 0
	Local nAux			:= 0
	Local cAliasSA1		:= GetNextAlias()
	Default oself:searchKey 	:= ''
	Default oself:branch		:= ''
	Default oself:page		:= 1
	Default oself:pageSize	:= 20
	Default oself:byId		:=.F.
	// Tratativas para realizar os filtros
	If !Empty(oself:searchKey) //se tiver chave de busca no request
		cSearch := Upper( oself:SearchKey )
		If oself:byId //se filtra somente por ID
			cWhere += " AND SA1.A1_COD = '"	+ cSearch + "'"
		Else//busca chave nos campos abaixo
			cWhere += " AND ( SA1.A1_COD LIKE 	'%"	+ cSearch + "%' OR "
			cWhere	+= " SA1.A1_LOJA   LIKE 	'%" + cSearch + "%' OR "
			cWhere	+= " SA1.A1_NOME   LIKE 	'%" + FwNoAccent( cSearch ) + "%' OR "
			cWhere	+= " SA1.A1_NREDUZ LIKE 	'%" + FwNoAccent( cSearch ) + "%' OR "
			cWhere	+= " SA1.A1_NREDUZ LIKE 	'%" + cSearch  + "%' OR "
			cWhere	+= " SA1.A1_CGC	   LIKE 	'%" + cSearch  + "%' OR "	
			cWhere	+= " SA1.A1_NOME   LIKE 	'%" + cSearch + "%' ) "
		EndIf
	EndIf
	If !Empty(oself:branch) 
		cWhere += " AND SA1.A1_LOJA = '"+oself:branch+"'"
	EndIf
	dbSelectArea('SA1')
	DbSetOrder(1)
	If SA1->( Columnpos('A1_MSBLQL') > 0 ) 
		cWhere += " AND SA1.A1_MSBLQL <> '1'"
	EndIf
	cWhere := '%'+cWhere+'%' 
	// Realiza a query para selecionar clientes
	BEGINSQL Alias cAliasSA1
		SELECT SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.A1_END
		FROM 	%table:SA1% SA1
		WHERE 	SA1.%NotDel%
		%exp:cWhere%
		ORDER BY A1_COD
	ENDSQL
	If ( cAliasSA1 )->( ! Eof() )
	
		// Identifica a quantidade de registro no alias temporário
		COUNT TO nRecord
		
		If oself:page > 1
			nStart := ( ( oself:page - 1 ) * oself:pageSize ) + 1
			nReg := nRecord - nStart + 1
		Else
			nReg := nRecord
		EndIf

		// Posiciona no primeiro registro.
		( cAliasSA1 )->( DBGoTop() )

		// Valida a exitencia de mais paginas
		If nReg  > oself:pageSize
			oJsonCli['hasNext'] := .T.
		Else
			oJsonCli['hasNext'] := .F.
		EndIf
	Else
		// Nao encontrou registros
		oJsonCli['hasNext'] := .F.
	EndIf

	//Array de clientes
	While ( cAliasSA1 )->( ! Eof() )
		nCount++
		If nCount >= nStart
			nAux++
		    aAdd( aListCli , JsonObject():New() )
			aListCli[nAux]['id']	:= ( cAliasSA1 )->A1_COD
			aListCli[nAux]['name']	:= Alltrim( EncodeUTF8( ( cAliasSA1 )->A1_NOME ) )
			aListCli[nAux]['branch']	:= ( cAliasSA1 )->A1_LOJA
			aListCli[nAux]['address']	:= ( cAliasSA1 )->A1_END
			If Len(aListCli) >= oself:pageSize
				Exit
			EndIf
		EndIf
		( cAliasSA1 )->( DBSkip() )
	End
	( cAliasSA1 )->( DBCloseArea() )
	oJsonCli['clients'] := aListCli
	
	//Serializa objeto Json
	cJsonCli:= FwJsonSerialize( oJsonCli )
	
	//Limpa objeto da memoria
	FreeObj(oJsonCli)
	oself:SetResponse( cJsonCli )
Return .T.