module Main (main) where

import Control.Monad (unless)
import Environment
    ( destino
    , episodioTerminado
    , getReward
    , origem
    )
import QLearning
    ( Config(..)
    , melhorAcao
    , treinar
    )
import System.Exit (exitFailure)

main :: IO ()
main = do
    assert
        "o episodio termina em F"
        (episodioTerminado destino)

    assert
        "a recompensa do movimento A -> C e -4"
        (getReward origem "C" == Just (-4))

    let config = Config
            { cfgEpisodios = 5000
            , cfgAlpha = 0.1
            , cfgGamma = 1.0
            , cfgEpsilon = 0.2
            , cfgMaxPassos = 20
            }
        tabela = treinar config 42

    assert
        "o agente aprende C como melhor acao a partir de A"
        (melhorAcao tabela origem == Just "C")

    assert
        "o agente aprende E como melhor acao a partir de C"
        (melhorAcao tabela "C" == Just "E")

    assert
        "o agente aprende F como melhor acao a partir de E"
        (melhorAcao tabela "E" == Just "F")

    putStrLn "Testes concluidos."

assert :: String -> Bool -> IO ()
assert descricao condicao =
    unless condicao $ do
        putStrLn ("Falha: " ++ descricao)
        exitFailure
