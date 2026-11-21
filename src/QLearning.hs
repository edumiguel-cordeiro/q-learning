module QLearning
    ( Acao
    , TabelaQ
    , inicializarTabela
    , valorQ
    , maxValorQ
    , atualizarQ
    , alphaPadrao
    , gammaPadrao
    , Semente
    , Config(..)
    , configPadrao
    , escolherAcao
    , melhorAcao
    , executarEpisodio
    , treinar
    ) where

import Data.List       (foldl', maximumBy)
import Data.Map.Strict (insert, fromList, findWithDefault, Map)
import Data.Ord        (comparing)
import Environment     (Estado, episodioTerminado, opcoesDeslocamento, ruas, getReward, origem)

-- tabela
type Acao    = Estado
type TabelaQ = Map (Estado, Acao) Double

-- parâmetros
alphaPadrao :: Double
alphaPadrao = 0.1

gammaPadrao :: Double
gammaPadrao = 0.9

-- atualização
atualizarQ :: Double -> Double -> TabelaQ -> Estado -> Acao -> Double -> Estado -> TabelaQ
atualizarQ alpha gamma tabela estado acao recompensa proximoEstado =
    insert (estado, acao) novoValor tabela
  where
    valorAtual = valorQ tabela estado acao
    alvo = recompensa + gamma * maxValorQ tabela proximoEstado
    novoValor = valorAtual + alpha * (alvo - valorAtual)        -- Q(s, a) = Q(s, a) + alpha * (r + gamma * max Q(s', a') - Q(s, a))

-- funções úteis
inicializarTabela :: TabelaQ
inicializarTabela = fromList [ ((origemRua, destinoRua), 0) | (origemRua, destinoRua, _) <- ruas]

valorQ :: TabelaQ -> Estado -> Acao -> Double
valorQ tabela estado acao = findWithDefault 0 (estado, acao) tabela

maxValorQ :: TabelaQ -> Estado -> Double
maxValorQ tabela estado
    | episodioTerminado estado = 0
    | null acoes = 0
    | otherwise = maximum [ valorQ tabela estado acao | acao <- acoes ]
  where
    acoes = [ destinoRua | (_, destinoRua, _) <- opcoesDeslocamento estado ]


-- EPSILON-GREEDY
type Semente = Int

proximaSemente :: Semente -> Semente
proximaSemente s = (1103515245 * s + 12345) `mod` 2147483648

sorteio :: Semente -> Double
sorteio s = fromIntegral s / 2147483648

melhorAcao :: TabelaQ -> Estado -> Maybe Acao
melhorAcao tabela estado
    | null acoes = Nothing
    | otherwise  = Just (fst (maximumBy (comparing snd) pares))
  where
    acoes = [ d | (_, d, _) <- opcoesDeslocamento estado ]
    pares = [ (a, valorQ tabela estado a) | a <- acoes ]

escolherAcao :: Double -> TabelaQ -> Estado -> Semente -> (Maybe Acao, Semente)
escolherAcao epsilon tabela estado semente
    | null acoes = (Nothing, s2)
    | sorteio s1 < epsilon = (Just (acoes !! indice), s2)
    | otherwise = (melhorAcao tabela estado, s2)
  where
    acoes  = [ d | (_, d, _) <- opcoesDeslocamento estado ]
    s1     = proximaSemente semente
    s2     = proximaSemente s1
    n      = length acoes
    indice = min (n - 1) (floor (sorteio s2 * fromIntegral n))


-- TREINAMENTO
data Config = Config
    { cfgEpisodios :: Int
    , cfgAlpha     :: Double
    , cfgGamma     :: Double
    , cfgEpsilon   :: Double
    , cfgMaxPassos :: Int
    }

configPadrao :: Config
configPadrao = Config
    { cfgEpisodios = 1000
    , cfgAlpha     = alphaPadrao
    , cfgGamma     = gammaPadrao
    , cfgEpsilon   = 0.3
    , cfgMaxPassos = 20
    }

executarEpisodio :: Config -> TabelaQ -> Semente -> (TabelaQ, Semente)
executarEpisodio cfg tabelaInicial sementeInicial =
    passo origem tabelaInicial sementeInicial 0
  where
    passo estado tabela semente n
        | episodioTerminado estado || n >= cfgMaxPassos cfg = (tabela, semente)
        | otherwise =
            case escolherAcao (cfgEpsilon cfg) tabela estado semente of
                (Nothing, s')   -> (tabela, s')
                (Just acao, s') ->
                    case getReward estado acao of
                        Nothing -> (tabela, s')
                        Just recompensa ->
                            let novaTabela = atualizarQ (cfgAlpha cfg) (cfgGamma cfg)
                                                        tabela estado acao
                                                        (fromIntegral recompensa) acao
                            in passo acao novaTabela s' (n + 1)

treinar :: Config -> Semente -> TabelaQ
treinar cfg semente =
    fst (foldl' umEpisodio (inicializarTabela, semente) [1 .. cfgEpisodios cfg])
  where
    umEpisodio (tabela, s) _ = executarEpisodio cfg tabela s
