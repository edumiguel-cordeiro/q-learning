module QLearning
    ( Acao
    , TabelaQ
    , inicializarTabela
    , valorQ
    , maxValorQ
    , atualizarQ
    , alphaPadrao
    , gammaPadrao
    ) where

import Data.Map.Strict (insert, fromList, findWithDefault, Map)
import Environment (Estado, episodioTerminado, opcoesDeslocamento, ruas)

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