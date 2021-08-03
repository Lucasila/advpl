//Bibliotecas
#INCLUDE 'TOTVS.CH'
#INCLUDE 'Protheus.ch'

/*/{Protheus.doc} MA410MNU                                                                                       
    Desc: Adiciona item no menu outras ações relacionadas do Pedido de Vendas   
    @type  Function
    @author Lucas Silva Vieira
    @since 04/12/2020
/*/
User Function MA410MNU()
    Local aArea := GetArea()
     
    aadd(aRotina,{"Importar Pedidos do Log Estqoue","U_PEDLOG", 0,7,0, Nil}) 
    //ira chamar pedidolog onde o usuario ira informar o idCarga 
    RestArea(aArea)
    
Return
