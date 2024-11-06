import cartago.*;
import java.io.File;
import java.io.IOException;

public class RunCopy extends Artifact {
    @OPERATION
    void executarScript(String nome_agente, String destino) {
        try {
            String caminhoDoScript = "./copy_files.sh";

            File script = new File(caminhoDoScript);
            if (!script.exists()) {
                System.out.println("O script não foi encontrado.");
                return;
            }

            ProcessBuilder processBuilder = new ProcessBuilder("bash", caminhoDoScript, nome_agente, destino);
            processBuilder.inheritIO();
            Process process = processBuilder.start();

            int exitCode = process.waitFor();

            if (exitCode == 0) {
                log("Carteiras copiadas para smartParking com sucesso!");
            } else {
                log("Houve um erro na execução do script.");
            }
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
        }
    }
}
