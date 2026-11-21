module Printing (imprimirResultado) where

import Data.List   (intercalate)
import Environment (Estado, getReward, ruas)
import QLearning   (Config(..), TabelaQ, valorQ)

-- funções de impressão para o Main
imprimirResultado :: Config -> TabelaQ -> Maybe ([Estado], Int) -> IO ()
imprimirResultado config tabela rota = do
    putStrLn "Treinamento do agente de entregas"
    putStrLn ("Episodios: " ++ show (cfgEpisodios config))
    putStrLn ("Taxa de exploracao: " ++ show (cfgEpsilon config))
    putStrLn ("Fator de desconto: " ++ show (cfgGamma config))
    putStrLn ""
    putStrLn "Tabela Q aprendida:"
    print tabela

    case rota of
        Nothing ->
            putStrLn "O agente nao encontrou uma rota ate o destino dentro do limite de passos."
        Just (estados, recompensaTotal) -> do
            putStrLn ("\nRota escolhida: " ++ intercalate " -> " estados)
            putStrLn "\nMapa de ruas (==> indica a rota aprendida):"
            imprimirMapa estados
            putStrLn "Recompensas por deslocamento:"
            imprimirDeslocamentos tabela estados
            putStrLn ("Recompensa total da rota: " ++ show recompensaTotal)

imprimirMapa :: [Estado] -> IO ()
imprimirMapa rota =
    mapM_ imprimirRua ruas
  where
    trechosRota = zip rota (drop 1 rota)

    imprimirRua (estado, destino, custo)
        | (estado, destino) `elem` trechosRota =
            putStrLn
                ( "  " ++ estado ++ " ==" ++ show custo ++ "==> " ++ destino
                    ++ "  [rota]"
                )
        | otherwise =
            putStrLn
                ("  " ++ estado ++ " --" ++ show custo ++ "--> " ++ destino)

imprimirDeslocamentos :: TabelaQ -> [Estado] -> IO ()
imprimirDeslocamentos _ [] = pure ()
imprimirDeslocamentos _ [_] = pure ()
imprimirDeslocamentos tabela (estado : acao : restante) = do
    case getReward estado acao of
        Nothing -> putStrLn ("  " ++ estado ++ " -> " ++ acao ++ ": rua indisponivel")
        Just recompensa ->
            putStrLn
                ( "  " ++ estado ++ " -> " ++ acao
                    ++ ": recompensa " ++ show recompensa
                    ++ ", Q = " ++ show (valorQ tabela estado acao)
                )
    imprimirDeslocamentos tabela (acao : restante)
