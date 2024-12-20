// Agent bank in project chefBankGlutton
/* Initial beliefs and rules */
chainServer("http://testchain.chon.group:9984/").
// chainServer("http://localhost:9984/").

/* Initial goals */
!carregarCarteira.

/* Plans */
+!carregarCarteira: chainServer(Server) <-
	.broadcast(tell, chainServer(Server));
	.print("Obtendo carteira digital");
	.velluscinum.loadWallet(myWallet);
	.wait(myWallet(PrK,PuK));
	+bankWallet(PuK);

	.velluscinum.walletContent(Server, PrK, PuK, content);
    .wait(content(Content));
	!findToken(token, set(Content));
	.wait(cryptocurrency(Coin));
    
    !copiarCarteiras.

+!findToken(Term,set([Head|Tail])) <- 
    !compare(Term,Head,set(Tail));
    !findToken(Term,set(Tail)).

+!compare(Term,[Type,AssetID, Qtd],set(V)): (Term  == Type) | (Term == AssetID) <- 
    .print("Type: ", Type, " ID: ", AssetID," Qtd: ", Qtd);
	-+coinBalance(Qtd);
	+cryptocurrency(AssetID).

-!compare(Term,[Type,AssetID,Qtd],set(V)) <- .print("The Asset ",AssetID, " is not a ",Term).

-!findToken(Type,set([   ])): not cryptocurrency(Coin) <- 
	.print("Moeda Nao encontrada");
	!criarMoeda.

-!findToken(Type,set([   ])): cryptocurrency(Coin) <- 
	.print("Moeda ja na carteira").
	
+!criarMoeda: chainServer(Server) & myWallet(PrK, PuK) <- 
	.print("Criando moeda");
	.velluscinum.deployToken(Server, PrK, PuK, "name:cryptocurrency", 300000, cryptocurrency);
	+coinBalance(300000);
	.wait(cryptocurrency(Coin)).

+!lending(ClientWallet, Value)[source(Client)]: 
			cryptocurrency(Coin) & coinBalance(Amount) & myWallet(PrK,PuK) & chainServer(Server) <-
	// .print("Olá agente ",Client,", Bem vindo ao SmartBank!");
	// .velluscinum.stampTransaction(Server,PrK,PuK,ResquestNumber,loan(Client));
	if (Amount >= Value) {
		// .print("Transferência validada. Aguarde enquanto processamos a transação.");
		.velluscinum.transferToken(Server,PrK,PuK,Coin,ClientWallet,1000,transactionTransfer);
		.print("Transação processada com sucesso. Obrigado por escolher o SmartBank! => ", Client);
		.send(Client,tell,bankAccount(ok));
	} else {
		.print("Não há saldo suficiente para esta moeda. Transação cancelada. Obrigado por escolher o SmartBank!");
		.send(Client,tell,bankAccount(fail));
	}.

+!copiarCarteiras <-
	lookupArtifact("runCopy", CopyId);
    focus(CopyId);
    .my_name(Nome);
    executarScript(Nome).

