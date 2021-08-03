#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

User Function TstRest(cIdCarga As Character) As Logical
    Local lRet          As Logical
    Local cResponse     As Character
    //variavel do array    
    Local cRevenda      As Character //"COD_REVENDA": "1097",
    Local cRevfat       As Character //"REVENDA_FATURAMENTO": "ATM UDIA DISTRIBUIDORA DE BEBIDAS LTDA",
    Local cIdgrade      As Character //"ID_GRADE": 1612,
    Local cIdcarga1      As Character //"ID_CARGA": "4921",
    Local cCodprod      As Character //"COD_CCIP": "410010010",
    Local cDescprod     As Character //"DESCRICAO": "CERVEJA IMPERIO PILSEN LATA 350ML CX C/12",
    //Local cQtda         As Character //"QTDE": 572,
    //Local cVenda        As Character //"VENDA": 458,
    //Local cTotal        As Character //"TOTAL"

    Local oRestClient   As Object
    Local oJson         As Object
    Local aArea     := GetArea()
    Local aCabec
    Local aItens    := {}
    Local aLinha    := {}

    lRet    := .T.

    cResponse   := ''

    Default cIdCarga := ''
        
    oRestClient := FWRest():New('https://logestoque.ddns.com.br:3000/bi_grade/'+AllTrim(cIdCarga)+'/todos/todos/todos/todos/todos/todos/todos/todos')

    oRestClient:SetPath('')
    IF oRestClient:Get()
        cResponse   := oRestClient:GetResult()
        QOUT(cResponse)       
        oJson := JsonObject():New()
        oJson:FromJson(cResponse)

        cRevenda  := oJson[1]['COD_REVENDA']
        cRevfat   := oJson[1]['REVENDA_FATURAMENTO']
        cIdcarga1 := oJson[1]['ID_GRADE']
        cIdgrade  := oJson[1]['ID_CARGA']
        cCodprod  := oJson[1]['COD_CCIP']
        cDescprod := oJson[1]['DESCRICAO']
        //Alert('Codigo de Revenda: '+cRevenda+ 'Revenda Faturamento: '+cRevfat,'Informações do pedido')

        DEFINE DIALOG oDlg TITLE 'Importar pedido do Log Estoque' FROM 0,0  TO 310,400 COLOR CLR_BLACK,CLR_WHITE PIXEL
            @ 040, 020 SAY oSay PROMPT cIdcarga1  SIZE 300, 012 OF oDlg PIXEL
            @ 060, 020 SAY oSay PROMPT cIdgrade   SIZE 300, 012 OF oDlg PIXEL
            @ 020, 020 SAY oSay PROMPT cRevfat   SIZE 300, 012 OF oDlg PIXEL
            @ 080, 020 SAY oSay PROMPT cDescprod   SIZE 300, 012 OF oDlg PIXEL
            @ 140, 020 BUTTON oButton1 PROMPT 'OK' SIZE 037, 012 OF oDlg PIXEL
        ACTIVATE DIALOG oDlg CENTERED 

    DbSelectArea(cAlias)
    (cAlias)->(dbSetOrder(1))
    IF ((cAlias)->(dbSeek(FWxFilial(cAlias)+PadR(oJson:GetJsonObject('CLIENTE'),TamSX3("A1_COD")[1])+PadR(oJson:GetJsonObject('LOJACLI'),TamSX3("A1_LOJA")[1]))))
        aCabec  := {}
        aItens  := {}

        aAdd(aCabec,{"C5_TIPO",     AllTrim(oJson:GetJsonObject('TIPO'))   ,        NIL})
        aAdd(aCabec,{"C5_CLIENTE",  AllTrim(oJson:GetJsonObject('CLIENTE')),        NIL})
        aAdd(aCabec,{"C5_LOJACLI",  AllTrim(oJson:GetJsonObject('LOJACLI')),        NIL})
        aAdd(aCabec,{"C5_CLIENT",   AllTrim(oJson:GetJsonObject('CLIENTE')),        NIL})
        aAdd(aCabec,{"C5_LOJAENT",  AllTrim(oJson:GetJsonObject('LOJACLI')),        NIL})
        aAdd(aCabec,{"C5_TPFRETE",  AllTrim(oJson:GetJsonObject('TPFRETE')),        NIL})
        aAdd(aCabec,{"C5_CONDPAG",  AllTrim(oJson:GetJsonObject('CONDPAG')),        NIL})
        aAdd(aCabec,{"C5_MENNOTA",  AllTrim(oJson:GetJsonObject('MENNOTA')),        NIL})
        aAdd(aCabec,{"C5_NATUREZ",  AllTrim(oJson:GetJsonObject('NATUREZ')),        NIL})

        //Busca os itens no JSON, percorre eles e adiciona no array da SC6
        oItems  := oJson:GetJsonObject('Items')
        For nX  := 1 To Len (oItems)
            aLinha  := {}
            aAdd(aLinha,{"C6_ITEM",     AllTrim(oItems[nX]:GetJsonObject('ITEM')),              NIL})
            aAdd(aLinha,{"C6_PRODUTO",  AllTrim(oItems[nX]:GetJsonObject('PRODUTO')),           NIL})
            aAdd(aLinha,{"C6_QTDVEN",   oItems[nX]:GetJsonObject('QTDVEN'),                     NIL})
            aAdd(aLinha,{"C6_PRCVEN",   oItems[nX]:GetJsonObject('PRCVEN'),                     NIL})
            aAdd(aLinha,{"C6_VALOR",    oItems[nX]:GetJsonObject('VALOR'),                      NIL})
            aAdd(aLinha,{"C6_TES",      AllTrim(oItems[nX]:GetJsonObject('TES')),               NIL})
            aAdd(aLinha,{"C6_ENTREG",   (ddatabase - 1),                                        NIL})
            //Campos opcionais
            IIF(!EMPTY(oItems[nX]:GetJsonObject('CONTA')),  aAdd(aLinha,{"C6_CONTA",     AllTrim(oItems[nX]:GetJsonObject('CONTA')),         NIL}),)
            IIF(!EMPTY(oItems[nX]:GetJsonObject('CC')),     aAdd(aLinha,{"C6_CC",        AllTrim(oItems[nX]:GetJsonObject('CC')),            NIL}),'')
            //Só grava os dados de projeto se for enviado projeto, tarefa e edt
            IF (!EMPTY(oItems[nX]:GetJsonObject('PROJPMS')) .and. !EMPTY(oItems[nX]:GetJsonObject('REVISAO')) .and. !EMPTY(oItems[nX]:GetJsonObject('TASKPMS')))
                aAdd(aLinha,{"C6_PROJPMS",   AllTrim(oItems[nX]:GetJsonObject('PROJPMS')),       NIL})
                aAdd(aLinha,{"C6_REVISAO",    AllTrim(oItems[nX]:GetJsonObject('REVISAO')),      NIL})
                aAdd(aLinha,{"C6_TASKPMS",   AllTrim(oItems[nX]:GetJsonObject('TASKPMS')),       NIL})
            EndIF

            aAdd(aItens,aLinha)
        Next nX
        //Chama a inclusão automática de pedido de venda
        MsExecAuto({|x, y, z| mata410(x, y, z)},aCabec,aItens,nOpc)
        //Caso haja erro inicia o tratamento e retorno do mensagem
        IF lMsErroAuto
            aLog        := GetAutoGRLog()
            //Aqui só me interessa a primeira linha do erro
            cErrorAuto += RTRIM(aLog[1])
            //Montando JSON de retorno
            //cJsonRet := '{"RETURN":"FALSE"';
                //    + ',"MESSAGE":"'  + EncodeUTF8(substring(cErrorAuto,1,200)) +'"}'
            //Retornando erro para o client
            SetRestFault(400,cErrorAuto,.T.,/* nStatus */,/* cDetailMsg */,'erplabs.com.br',aLog)

            lRet := .F.
        ELSE
            cJsonRet := '{"NUM":"' + SC5->C5_NUM	+ '"';
                + ',"RETURN":"TRUE"';
                + ',"MESSAGE":"'  + "Cadastrado com sucesso."+ '"'+'}'
            Self:SetResponse(cJsonRet)
        EndIF
    ELSE
        cError := "Cliente não encontrado"
        cJsonRet := '{"RETURN":"FALSE"';
            + ',"MESSAGE":"'  + EncodeUTF8(substring(cError,1,200)) +'"}'

            SetRestFault(500,cJsonRet,.T.,/* nStatus */,/* cDetailMsg */,'erplabs.com.br',)
            lRet := .F.
        EndIF
    EndIf
    RestArea(aArea)
    
    ELSE
        QOUT(oRestClient:GetLastError())
        lRet    := .F.
    EndIF
    FWFreeVar(oRestClient)
Return(lRet)
