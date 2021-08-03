/*/{Protheus.doc} User Function TstRest
    (Verbo POST para adição de pedidos de venda)
    @type  Function
    @author Lucas Silva Vieira
    @since 10/12/2020
    @version 1.0
/*/
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

#DEFINE TPFRETE                 "S"

User Function TstRest(cIdCarga As Character) As Logical
	Local lRet          As Logical
	Local cJsonRet     As Character
	//variavel do array
	//Local oCcarga
	Local oCtipo
	Local oCcliente
	Local oClojacli
	Local oCcondpag
	Local oCtipocli
	Local oCxrota
	Local oCvend1
	Local oCvend2
	Local oCfrete
	Local oCvolume1
	Local oCespeci1
	Local oCnaturez
	Local oCtabela
	Local oRestClient   As Object
	Local oJson         As Object
	Local aCabec
	Local aItens
	Local aLinha
	Local oItems
	Local nX        := 0
	//Local cAlias    := ''
	Local nOpc      := 3
	Private lMsErroAuto := .F.

	lRet    := .T.
	cJsonRet   := ''

	Default cIdCarga := ''

	//oRestClient := FWRest():New('https://logestoque.ddns.com.br:3000/bi_grade/'+AllTrim(cIdCarga)+'/todos/todos/todos/todos/todos/todos/todos/todos')
	oRestClient := FWRest():New('https://logestoque.ddns.com.br:3000/totvs_pedido/'+AllTrim(cIdCarga)+'')
	oRestClient:SetPath('')
	IF oRestClient:Get()
		cJsonRet   := oRestClient:GetResult()
		QOUT(cJsonRet)
		oJson := JsonObject():New()
		MemoWrite("C:\TOTVS\Teste\pedidos.json", cJsonRet)
		oJson:FromJson(cJsonRet)

		oCcarga   := oJson[1]['ID_CARGA']
		oCtipo    := oJson[1]['C5_TIPO']
		oCcliente := oJson[1]['C5_CLIENTE']
		oClojacli := oJson[1]['C5_LOJACLI']
		oCcondpag := oJson[1]['C5_CONDPAG']
		oCtipocli := oJson[1]['C5_TIPOCLI']
		oCxrota   := oJson[1]['C5_XROTA']
		oCvend1   := oJson[1]['C5_VEND1']
		oCvend2   := oJson[1]['C5_VEND2']
		oCfrete   := oJson[1]['C5_FRETE']
		oCvolume1 := oJson[1]['C5_VOLUME1']
		oCespeci1 := oJson[1]['C5_ESPECI1']
		oCnaturez := oJson[1]['C5_NATUREZ']
		oCtabela  := oJson[1]['C5_TABELA']

        DEFINE DIALOG oDlg TITLE 'Importar pedido do Log Estoque' FROM 0,0  TO 180,400 COLOR CLR_BLACK,CLR_WHITE PIXEL
            @ 020, 020 SAY oSay PROMPT 'ID Carga: '  SIZE 300, 050 OF oDlg PIXEL
            @ 028, 020 SAY oSay PROMPT oCcarga  SIZE 300, 050 OF oDlg PIXEL
            @ 040, 020 SAY oSay PROMPT 'Cliente:'    SIZE 300, 050 OF oDlg PIXEL
            @ 048, 020 SAY oSay PROMPT '00'+oCcliente SIZE 300, 050 OF oDlg PIXEL
            @ 060, 020 BUTTON oButton1 PROMPT 'OK' ACTION (oDlg:End()) SIZE 037, 012 OF oDlg PIXEL
            
        ACTIVATE DIALOG oDlg CENTERED 

        /*VALIDAÇÃO - VERIFICA SER O CODIGO DO CLINTE EXISTE
            DbSelectArea(cAlias)
            (cAlias)->(dbSetOrder(1))
		IF ((cAlias)->(dbSeek(FWxFilial(cAlias)+PadR(oJson[1]['C5_CLIENTE'],TamSX3("A1_COD")[1])+PadR(oJson[1]['C5_LOJACLI'],TamSX3("A1_LOJA")[1]))))
		*/
			aCabec  := {}
			aItens  := {}

        /* Existe geração de numeração automatica
            GetSXENum("SC5","C5_NUM")
            aAdd(aCabec,{"C5_NUM",        AllTrim(oJson[1][NUM'))   ,          NIL}) 
        */
			aAdd(aCabec,{"C5_TIPO",         AllTrim(oJson[1]['C5_TIPO']),    NIL})
			aAdd(aCabec,{"C5_CLIENTE",      AllTrim('00'+oCcliente), NIL})
			aAdd(aCabec,{"C5_LOJACLI",      AllTrim('0'+oClojacli), NIL})
			aAdd(aCabec,{"C5_CONDPAG",      AllTrim('0'+oCcondpag), NIL})
			aAdd(aCabec,{"C5_NATUREZ",		AllTrim(oJson[1]['C5_NATUREZ']), NIL})
			aAdd(aCabec,{"C5_TIPOCLI",      AllTrim(oJson[1]['C5_TIPOCLI']), NIL})
			aAdd(aCabec,{"C5_XROTA",        AllTrim(oJson[1]['C5_XROTA']),   NIL})
			aAdd(aCabec,{"C5_VEND1",        AllTrim('0000'+oCvend1),   NIL})
			//aAdd(aCabec,{"C5_VEND2",        AllTrim(oJson[1]['C5_VEND2']),   NIL})
			aAdd(aCabec,{"C5_TRANSP",       AllTrim(oJson[1]['C5_TRANSP']),  NIL})
			aAdd(aCabec,{"C5_IDCARGA",      AllTrim(cIdCarga),  			 NIL})
			/*
				C (0) - Por conta do emitente (CIF);
				F (1) - Por conta do destinatário/remetente (FOB);
				T (2) - Por conta de terceiros;
				R (3) - Transporte Próprio por conta do Remetente;
				D (4) - Transporte Próprio por conta do Destinatário;
				S (9) - Sem cobrança de frete.
			*/
			aAdd(aCabec,{"C5_TPFRETE",      TPFRETE, NIL})
			aAdd(aCabec,{"C5_IDCARGA",      AllTrim(oJson[1]['C5_IDCARGA']), NIL})
			aAdd(aCabec,{"C5_VOLUME1",      AllTrim(oJson[1]['C5_VOLUME1']), NIL})
			aAdd(aCabec,{"C5_ESPECI1",      AllTrim(oJson[1]['C5_ESPECI1']), NIL})

			//Busca os itens no JSON, percorre eles e adiciona no array da SC6
           oItems  := oJson:GetJsonObject('ITEMS')
			//For nX  := 1 To Len (oJson)
			For nX:= 1 To Len(oJson[1]['ITEMS'])
                aLinha  := {}
                //Alert('O código de cada um dos produtos é: ' +oJson[1]['ITEMS'][nX]['C6_PRODUTO'])
				aAdd(aLinha,{"C6_ITEM",     StrZero(nX,2),                                       NIL})
				aAdd(aLinha,{"C6_PRODUTO",  AllTrim(oJson[1]['ITEMS'][nX]['C6_PRODUTO']),        NIL})
				aAdd(aLinha,{"C6_QTDVEN",   oJson[1]['ITEMS'][nX]['C6_QTDVEN'],                  NIL})
                aAdd(aLinha,{"C6_PRCVEN",   oJson[1]['ITEMS'][nX]['C6_PRCVEN'],                  NIL})
                aAdd(aLinha,{"C6_VALOR",    oJson[1]['ITEMS'][nX]['C6_VALOR'],                   NIL})
                aAdd(aLinha,{"C6_TES",      AllTrim(oJson[1]['ITEMS'][nX]['C6_TES']),       	 NIL})
            aAdd(aItens,aLinha)
			Next nX
            
			//Chama a inclusão automática de pedido de venda
			MsExecAuto({|x, y, z| mata410(x, y, z)},aCabec,aItens,nOpc)
			
			If !lMsErroAuto
                         ALERT("Pedido Incluido com sucesso! ")
			Else
                        ALERT("Erro na inclusao!")
                         Mostraerro()      
                         aCabec := {}   // monta SC5
                         aItens := {}
			Endif
    /*VALIDAÇÃO DO CLIENTE
		ELSE
        cError := "Cliente não encontrado"
        cJsonRet := '{"RETURN":"FALSE"';
            + ',"MESSAGE":"'  + EncodeUTF8(substring(cError,1,200)) +'"}'
 
        SetRestFault(500,cJsonRet,.T.,,,'',)
        lRet := .F.
		EndIF
    RestArea(aArea)
    */
	ELSE
		QOUT(oRestClient:GetLastError())
		lRet    := .F.
	EndIF
	FWFreeVar(oRestClient)
Return(lRet)
