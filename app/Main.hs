module Main (main) where

import Environment (Estado, episodioTerminado, getReward, origem)
import Printing    (imprimirResultado)
import QLearning   ( Config(..)
                   , TabelaQ
                   , configPadrao
                   , melhorAcao
                   , treinar
                   )

main :: IO ()
main = do
    let config = configPadrao
            { cfgEpisodios = 5000
            , cfgEpsilon = 0.2
            , cfgGamma = 1.0
            }
        tabelaAprendida = treinar config 42
        rota = rotaAprendida tabelaAprendida origem (cfgMaxPassos config)
    imprimirResultado config tabelaAprendida rota

rotaAprendida :: TabelaQ -> Estado -> Int -> Maybe ([Estado], Int)
rotaAprendida _ estado _ | episodioTerminado estado = Just ([estado], 0)
rotaAprendida _ _ passos | passos <= 0 = Nothing
rotaAprendida tabela estado passos = do
    acao <- melhorAcao tabela estado
    recompensa <- getReward estado acao
    (rota, recompensaFutura) <- rotaAprendida tabela acao (passos - 1)
    pure (estado : rota, recompensa + recompensaFutura)
