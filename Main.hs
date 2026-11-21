module Main (main) where

import Data.Maybe (fromMaybe)

import Environment (getReward)
import QLearning (alphaPadrao, atualizarQ, gammaPadrao, inicializarTabela, valorQ)

main :: IO ()
main = do
    let tabelaInicial = inicializarTabela
        recompensa = fromIntegral (fromMaybe 0 (getReward "A" "B"))
        tabelaAtualizada =
            atualizarQ alphaPadrao gammaPadrao tabelaInicial "A" "B" recompensa "B"

    putStrLn "Tabela Q inicial:"
    print tabelaInicial

    putStrLn "\nRecompensa ao ir de A para B:"
    print recompensa

    putStrLn "\nValor Q(A, B) antes da atualizacao:"
    print (valorQ tabelaInicial "A" "B")

    putStrLn "\nValor Q(A, B) depois da atualizacao:"
    print (valorQ tabelaAtualizada "A" "B")