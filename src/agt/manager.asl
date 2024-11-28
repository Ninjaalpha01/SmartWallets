{ include("$jacamo/templates/common-cartago.asl") }
{ include("$jacamo/templates/common-moise.asl") }

/* Initial beliefs */
listaVagas([ ]). // talvez de erro

/* Initial goals */
!criarCarteira.

/* plans */
+!criarCarteira <-
	.print("Obtendo carteira digital!");
	.velluscinum.loadWallet(myWallet);
	.wait(myWallet(PrK,PuK));
	+managerWallet(PuK);
	.wait(5000);
	!verificarListaVagas;
    !copiarCarteira.

+!copiarCarteira <-
    lookupArtifact("runCopy", CopyId);
    focus(CopyId);
    .my_name(Nome);
    executarScript(Nome);
	.print(Nome, " pronto");
	.kill_agent(Nome).

+!stampProcess(Transfer)[source(self)] : chainServer(Server) 
            & myWallet(PrK,PuK) <-
	.velluscinum.stampTransaction(Server,PrK,PuK,Transfer).

+vaga(Vaga): listaVagas(Lista) & not .empty(Lista) <- 
	-+listaVagas([Vaga|Lista]).

+vaga(Vaga) <- -+listaVagas([Vaga]).

+!verificarListaVagas: chainServer(Server) & myWallet(PrK,PuK) <-
	.print("Verificando lista de vagas...");
	.velluscinum.walletContent(Server, PrK, PuK, content);
	.wait(content(Content));
	!findToken(nft, set(Content)).

+!verificarListaVagas: not chainServer(Server) <-
	.wait(5000);
	!verificarListaVagas.
    
+!listarVagas: chainServer(Server) & myWallet(PrK,PuK) <- 
    !criarVagasCurta(1, Server, PrK, PuK, VagasCurta);
    !criarVagasLonga(1, Server, PrK, PuK, VagasLonga);
    !criarVagasCurtaCoberta(1, Server, PrK, PuK, VagasCurtaCoberta);
    !criarVagasLongaCoberta(1, Server, PrK, PuK, VagasLongaCoberta);
    .concat(VagasCurta, VagasLonga, VagasCurtaCoberta, VagasLongaCoberta, Lista);
    -+listaVagas(Lista).

+!criarVagasCurta(Qtd, Server, PrK, PuK, Vagas) <- 
    !criarVagas("Curta", Qtd, Server, PrK, PuK, Vagas).

+!criarVagasLonga(Qtd, Server, PrK, PuK, Vagas) <- 
    !criarVagas("Longa", Qtd, Server, PrK, PuK, Vagas).

+!criarVagasCurtaCoberta(Qtd, Server, PrK, PuK, Vagas) <- 
    !criarVagas("CurtaCoberta", Qtd, Server, PrK, PuK, Vagas).

+!criarVagasLongaCoberta(Qtd, Server, PrK, PuK, Vagas) <- 
    !criarVagas("LongaCoberta", Qtd, Server, PrK, PuK, Vagas).

+!criarVagas(Tipo, Qtd, Server, PrK, PuK, Vagas) <- 
    !criarVagasAux(Tipo, Qtd, Server, PrK, PuK, [], Vagas).

+!criarVagasAux(Tipo, 0, Server, PrK, PuK, Vagas, Vagas) <- 
    true.

+!criarVagasAux(Tipo, Qtd, Server, PrK, PuK, VagasAcumuladas, Vagas) <- 
    .concat("name:Vaga", Qtd, NomeVaga);
    .concat(NomeVaga, ";tipo:", Tipo, DescricaoVaga);
    .velluscinum.deployNFT(Server, PrK, PuK, DescricaoVaga, "status:disponivel", account);
    .wait(account(VagaId));
    NovaLista = [VagaId | VagasAcumuladas];
    NovoQtd = Qtd - 1;
    !criarVagasAux(Tipo, NovoQtd, Server, PrK, PuK, NovaLista, Vagas).

-!listarVagas <-
	.print("Nao foi possivel listar as vagas").

+!findToken(Term,set([Head|Tail])) <- 
    !compare(Term,Head,set(Tail));
    !findToken(Term,set(Tail)).

+!compare(Term,[Type,AssetId, Qtd],set(V)): (Term  == Type) | (Term == AssetId) <-
	+vaga(AssetId).

-!compare(Term,[Type,AssetId,Qtd],set(V)) <- .print("The Asset ",AssetId, " is not a ",Term).

-!findToken(Type,set([   ])): not vaga(Vaga) <- 
	.print("Lista de vagas nao encontrada");
	!listarVagas.

-!findToken(Type,set([   ])): vaga(Vaga) <- 
	.print("Vagas ja cadastradas").

