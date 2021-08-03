#include 'protheus.ch'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

#DEFINE VEND1					"000014" //Pegar informação do arquivo json
#DEFINE VEND2					"000001" //Pegar informação do arquivo json
#DEFINE TRANSP					"000001" //Pegar informação do arquivo json
#DEFINE TES						"999" //criar um tes padrão para todas as filiais 
#DEFINE ARMAZEM 				"01"	

/*/{Protheus.doc} User Function TstRest
    (Verbo POST para adição de pedidos de venda)
    @type  Function
    @author Lucas Silva Vieira
    @since 10/12/2020
    @version 1.0
/*/

User Function TstRest(cIdCarga As Character) As Logical
	Local lRet          As Logical
	Local cJsonRet      As Character
	Local oRestClient   As Object
	Local oJson         As Object
	Local oCtipo
	Local oCcliente
	Local cNomeCli:=""
	Local oClojacli
	Local oCcondpag
	Local oCtipocli
	Local oCxrota
	Local oCfrete
	Local oCvolume1
	Local oCespeci1
	Local oCnaturez
	Local oCtabela
	Local aCabec
	Local aItens
	Local aLinha
	Local oItems
	Local cNum := ''
	Local cProduto
	Local cCentro
	Local cConta
	Local cNatureza
	Local nX        := 0
	Local nOpc      := 3
	Private lMsErroAuto := .F.

	lRet    := .T.
	cJsonRet   := ''

	Default cIdCarga := ''

	DbSelectArea("SA1")
	DbSelectArea("SC5")
	DbSelectArea("SB1")

	SC5->(dbSetOrder(10))//criar indice no configurador e passar o numero no dbSetOrder(N)
	SB1->(dbSetOrder(1))
	SA1->(dbSetOrder(1))

	//verifica se existe cIdCarga 
	IF SC5->(DbSeek(xFilial("SC5")+cIdCarga))
			MsgInfo("ID Carga ja existe! Por Favor informe outro ID Carga")
	ELSE
		oRestClient := FWRest():New('https://logestoque.ddns.com.br:3000/totvs_pedido/'+AllTrim(cIdCarga)+'')
		oRestClient:SetPath('')
		IF oRestClient:Get()
			cJsonRet   := oRestClient:GetResult()
			QOUT(cJsonRet)
			oJson := JsonObject():New()
			oJson:FromJson(cJsonRet)

			oCcarga   := oJson[1]['ID_CARGA']
			oCtipo    := oJson[1]['C5_TIPO']
			oCcliente := oJson[1]['C5_CLIENTE']
			oClojacli := oJson[1]['C5_LOJACLI']
			oCcondpag := oJson[1]['C5_CONDPAG']
			oCtipocli := oJson[1]['C5_TIPOCLI']
			oCxrota   := oJson[1]['C5_XROTA']
			oCfrete   := oJson[1]['C5_FRETE']
			oCvolume1 := oJson[1]['C5_VOLUME1']
			oCespeci1 := oJson[1]['C5_ESPECI1']
			oCnaturez := oJson[1]['C5_NATUREZ']
			oCtabela  := oJson[1]['C5_TABELA']

			//Retorna nome do cliente
			cNomeCli := POSICIONE('SA1',1,XFILIAL('SA1')+Strzero(oCcliente,6)+Strzero(oClojacli,2),'A1_NOME')

			DEFINE DIALOG oDlg TITLE 'Importar pedido do Log Estoque' FROM 0,0  TO 180,400 COLOR CLR_BLACK,CLR_WHITE PIXEL
			@ 020, 020 SAY oSay PROMPT 'ID Carga: '  SIZE 300, 050 OF oDlg PIXEL
			@ 028, 020 SAY oSay PROMPT oCcarga  SIZE 300, 050 OF oDlg PIXEL
			@ 040, 020 SAY oSay PROMPT 'Cliente: ' SIZE 300, 050 OF oDlg PIXEL 
			@ 048, 020 SAY oSay PROMPT Strzero(oCcliente,6) +' : '+ cNomeCli SIZE 300, 050 OF oDlg PIXEL
			@ 060, 020 BUTTON oButton1 PROMPT 'OK' ACTION (oDlg:End()) SIZE 037, 012 OF oDlg PIXEL
			ACTIVATE DIALOG oDlg CENTERED

			//Verifica se o cliente 
			IF SA1->(DbSeek(xFilial("SA1")+Strzero(oCcliente,6)+Strzero(oClojacli,2)))
			
			//Retorna a natureza do Cliente
			cNatureza := Alltrim(POSICIONE('SA1',1,XFILIAL('SA1')+Strzero(oCcliente,6)+Strzero(oClojacli,2),'A1_NATUREZ'))
			
				aCabec  := {}
				aItens  := {}

				cNum:= GetSXENum("SC5","C5_NUM")
				aAdd(aCabec,{"C5_NUM",      	cNum   ,NIL}) //validar se e necessario 
				aAdd(aCabec,{"C5_TIPO",         AllTrim(oJson[1]['C5_TIPO']),    NIL})
				aAdd(aCabec,{"C5_CLIENTE",      AllTrim(Strzero(oCcliente,6)), NIL})
				aAdd(aCabec,{"C5_LOJACLI",      AllTrim(Strzero(oClojacli,2)), NIL})
				aAdd(aCabec,{"C5_CONDPAG",      AllTrim(Strzero(oCcondpag,3)), NIL})
				aAdd(aCabec,{"C5_NATUREZ",		cNatureza, NIL})
				aAdd(aCabec,{"C5_TIPOCLI",      AllTrim(oJson[1]['C5_TIPOCLI']), NIL})
				aAdd(aCabec,{"C5_XROTA",        AllTrim(oJson[1]['C5_XROTA']),   NIL})
				aAdd(aCabec,{"C5_VEND1",        VEND1,   NIL})
				aAdd(aCabec,{"C5_VEND2",        VEND2,   NIL})
				aAdd(aCabec,{"C5_TRANSP",       TRANSP,  NIL})
				aAdd(aCabec,{"C5_TPFRETE",      AllTrim(oCfrete), NIL})
				aAdd(aCabec,{"C5_IDCARGA",      AllTrim(oJson[1]['ID_CARGA']), NIL})
				aAdd(aCabec,{"C5_VOLUME1",      oJson[1]['C5_VOLUME1'], NIL})
				aAdd(aCabec,{"C5_ESPECI1",      AllTrim(oJson[1]['C5_ESPECI1']), NIL})

				//Busca os itens no JSON, percorre eles e adiciona no array da SC6
				oItems  := oJson:GetJsonObject('ITEMS')
				For nX:= 1 To Len(oJson[1]['ITEMS'])
					aLinha  := {}

					cProduto := AllTrim(oJson[1]['ITEMS'][nX]['C6_PRODUTO'])
					cConta   := Posicione('SB1',1,xfilial('SB1')+cProduto, "B1_CONTA")
					cCentro  := Posicione('SB1',1,xfilial('SB1')+cProduto, "B1_CC")

					aAdd(aLinha,{"C6_ITEM",     StrZero(nX,2),                                       NIL})
					aAdd(aLinha,{"C6_PRODUTO",  cProduto,       									 NIL})
					aAdd(aLinha,{"C6_QTDVEN",   oJson[1]['ITEMS'][nX]['C6_QTDVEN'],                  NIL})
					aAdd(aLinha,{"C6_PRCVEN",   oJson[1]['ITEMS'][nX]['C6_PRCVEN'],                  NIL})
					aAdd(aLinha,{"C6_VALOR",    Round((oJson[1]['ITEMS'][nX]['C6_QTDVEN']) * (oJson[1]['ITEMS'][nX]['C6_PRCVEN']),2) , NIL })
					aAdd(aLinha,{"C6_TES",      AllTrim(oJson[1]['ITEMS'][nX]['C6_TES']),      	 	 NIL})
					aAdd(aLinha,{"C6_CC",       AllTrim(cCentro),       	 									 NIL})
					aAdd(aLinha,{"C6_CONTA",    AllTrim(cConta),       	 									 NIL})
					aAdd(aLinha,{"C6_LOCAL",    "01",       	 									 NIL})
					aAdd(aItens,aLinha)
				Next nX
				
				//Chama a inclusão automática de pedido de venda
				MsExecAuto({|x, y, z| mata410(x, y, z)},aCabec,aItens,nOpc)

				If !lMsErroAuto
					MsgInfo("Pedido "+cNum+" incluido com sucesso! ", "Importação de Pedidos do Log Estoque.")
				Else
					ALERT("Erro na inclusao!")
					Mostraerro()
					aCabec := {}
					aItens := {}
				Endif

		//VALIDAÇÃO DO CLIENTE
			ELSE
				ALERT ("Cliente não encontrado!")
			EndIF
		DbCloseArea()
		ELSE
			QOUT(oRestClient:GetLastError())
			lRet    := .F.
		EndIF
		FWFreeVar(oRestClient)
	ENDIF	
	DbCloseArea() 
Return(lRet)
