#INCLUDE 'TOTVS.CH'

User Function PedLog()
    Local oButton1    As Object
    Local oButton2    As Object
    Local oGet        As Object
    Local oSay        As Object
    
    Local cGet        As Character
    
    Static oDlg        As Object
    
    cGet    := SPACE(04)

    DEFINE DIALOG oDlg TITLE 'Importar pedido do Log Estoque' FROM 0,0  TO 210,400 COLOR CLR_BLACK,CLR_WHITE PIXEL

    @ 020, 020 SAY oSay PROMPT "Informe o ID da Carga para realizar a importação do pedido." SIZE 150, 012 OF oDlg PIXEL
    @ 030, 020 GET oGet VAR cGet SIZE 150, 010 OF oDlg PIXEL
    @ 060, 020 BUTTON oButton1 PROMPT 'Importar' ACTION(U_TstRest(cGET)) SIZE 037, 012 OF oDlg PIXEL
    @ 060, 060 BUTTON oButton2 PROMPT 'Sair' ACTION (oDlg:End()) SIZE 037, 012 OF oDlg PIXEL

    ACTIVATE DIALOG oDlg CENTERED

Return
