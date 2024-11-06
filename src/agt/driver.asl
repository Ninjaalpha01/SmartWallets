{ include("$jacamo/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }

/* Initial beliefs */
// hoje
// amanha
// depois de amanha
datasReservas([
    "1729270800",
    "1729357200",
    "1729443600"
    ]).
tiposDeVaga(["Curta", "Longa", "CurtaCoberta", "LongaCoberta"]).

/* Initial goals */
!comecar.

/* Plans */
+!comecar <-
    !criarCarteira;
    !obterConteudoCarteira;
    .wait(coinBalance(Balance));
    !copiarCarteira.

+!copiarCarteira <-
    lookupArtifact("runCopy", CopyId);
    focus(CopyId);
    .my_name(Nome);
    executarScript(Nome);
	.print(Nome, " pronto");
	.kill_agent(Nome).

// ----------------- ACOES CARTEIRA -----------------

// +driverWallet(PuK) <- .send(manager, tell, driverWallet(PuK)).

+!criarCarteira : not myWallet(PrK,PuK) <-
    .print("Obtendo carteira digital...");
    .velluscinum.loadWallet(myWallet);
	.wait(myWallet(PrK,PuK));
    +driverWallet(PuK);
    
    .send(bank, askOne, chainServer(Server), Chain);
    .wait(2000);
    +Chain;
    .send(bank, askOne, bankWallet(BankW), Wallet);
    .wait(2000);
    +Wallet;
    .send(bank, askOne, cryptocurrency(Coin), ReplyCoin);
    .wait(2000);
    +ReplyCoin.

+!obterConteudoCarteira : chainServer(Server) & myWallet(PrK, PuK)
                & cryptocurrency(Coin) <-
    .abolish(listaNFTs(_));
    .abolish(coinBalance(_));
    .print("Obtendo conteudo da carteira...");
    .velluscinum.walletContent(Server, PrK, PuK, content);
    .wait(content(Content));
    !findToken(Coin, set(Content));
    !findToken(nft, set(Content)).

-!obterConteudoCarteira: not cryptocurrency(Coin) <-
    .send(bank, askOne, cryptocurrency(Coin), Reply);
    .wait(3000);
    +Reply;
    !obterConteudoCarteira.

-!obterConteudoCarteira <- 
    .print("Erro, tentando novamente...");
    .wait(10000);
    !obterConteudoCarteira.

+!findToken(Term,set([Head|Tail])) <- 
    !compare(Term,Head,set(Tail));
    !findToken(Term,set(Tail)).

+!compare(Term,[Type, AssetId, Qtd],set(V)) : (Term == AssetId) <- 
    .print("Moeda: ", AssetId);
	+coinBalance(Qtd);
    .print("Saldo atual: ", Qtd).

+!compare(Term,[Type,AssetId,Qtd],set(V)) : (Term == Type) & listaNFTs(Lista) <-    
    .print("Type: ", Type, " ID: ", AssetId);
    -+listaNFTs([AssetId|Lista]).

+!compare(Term,[Type,AssetId,Qtd],set(V)) : (Term == Type) & not listaNFTs(Lista) <-
    .print("Type: ", Type, " ID: ", AssetId);
    .concat(AssetId, Lista);
    +listaNFTs([Lista]).

-!compare(Term,[Type,AssetId,Qtd],set(V)).

-!findToken(Type,set([   ])) : not coinBalance(Amount) <- 
	.print("Moeda Nao encontrada");
    !pedirEmprestimo.

-!findToken(Type,set([   ])).

+!pedirEmprestimo : cryptocurrency(Coin) & bankWallet(BankW) 
            & chainServer(Server) & myWallet(PrK,PuK)
            & not pedindoEmprestimo <-
    +pedindoEmprestimo;
    if (emprestimoCount(Num)) {
        -+emprestimoCount(Num+1);
    } else {
        +emprestimoCount(1);
    }

	.print("Pedindo emprestimo...");
    ?emprestimoCount(Num);
    .concat("nome:motorista;emprestimo:", Num, Data);
	.velluscinum.deployNFT(Server, PrK, PuK, Data,
                "description:Creating Bank Account", account);
	.wait(account(AssetId));

	.velluscinum.transferNFT(Server, PrK, PuK, AssetId, BankW,
				"description:requesting lend;value_chainCoin:100",requestID);
	.wait(requestID(PP));
	
	.print("Lend Contract nr:",PP);
	.send(bank, achieve, lending(PP, PuK, 100));
    .wait(bankAccount(ok));
    .abolish(pedindoEmprestimo);
    !obterConteudoCarteira.

+!pedirEmprestimo(Valor)[source(self)] : cryptocurrency(Coin) & bankWallet(BankW) 
            & chainServer(Server) & myWallet(PrK,PuK)
            & not pedindoEmprestimo <-
    .print("dinheiro acabou, pedindo emprestimo");
    +pedindoEmprestimo;
    .abolish(bankAccount(_));

    .concat("nome:motorista;emprestimo:", Num, Data);
	.velluscinum.deployNFT(Server, PrK, PuK, Data,
                "description:Creating Bank Account", account);
	.wait(account(AssetId));

    .concat("description:requesting lend;value_chainCoin:", Valor, Descricao);
	.velluscinum.transferNFT(Server, PrK, PuK, AssetId, BankW, Descricao, requestID);
	.wait(requestID(PP));
	
	.print("Lend Contract nr:", PP);
	.send(bank, achieve, lending(PP, PuK, Valor));
    .wait(bankAccount(ok));
    .abolish(pedindoEmprestimo).

+!pedirEmprestimo : pedindoEmprestimo <-
    .print("Ja esta pedindo emprestimo").

-!pedirEmprestimo <-
    .print("Erro ao pedir emprestimo");
    .wait(5000);
    !pedirEmprestimo.

// ----- VALIDACAO -----
+!validarProcesso(TransacaoId)[source(self)] : chainServer(Server)
            & myWallet(PrK,PuK) <-
    .print("Validando transferencia...");
    .velluscinum.stampTransaction(Server, PrK, PuK, TransacaoId).

-!validarProcesso(TransacaoId) <- 
    .print("Erro ao validar transferencia, tentando novamente");
    !validarProcesso(TransacaoId).
