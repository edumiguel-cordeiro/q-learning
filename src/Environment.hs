module Environment
    ( Estado
    , episodioTerminado
    , opcoesDeslocamento
    , ruas
    , getReward
    , origem
    , destino
    ) where

-- Representa um ponto da cidade
type Ponto = String

-- Representa uma rua (origem, destino, custo)
type Rua = (Ponto, Ponto, Int)

-- Ruas e seus respectivos custos
ruas :: [Rua]
ruas =
    [ ("A", "B", 2)
    , ("A", "C", 4)
    , ("B", "D", 2)
    , ("B", "E", 5)
    , ("C", "D", 2)
    , ("C", "E", 2)
    , ("D", "F", 4)
    , ("E", "F", 1)
    ]

-- Ponto inicial e destino
origem :: Ponto
origem = "A"

destino :: Ponto
destino = "F"

-- Consulta o custo de uma rua entre dois pontos
custoRua :: Ponto -> Ponto -> Maybe Int
custoRua a b =
    case [(custo) | (origemRua, destinoRua, custo) <- ruas,
                    origemRua == a,
                    destinoRua == b] of
        [] -> Nothing
        (c:_) -> Just c


-- MOVIMENTAÇÃO DO AGENTE
type Estado = Ponto

-- 1. Identificar opções de deslocamento:
-- Dado um ponto atual, retorna todas as ruas (origem, destino, custo) que saem dele.
opcoesDeslocamento :: Ponto -> [Rua]
opcoesDeslocamento pontoAtual =
    [ rua | rua@(pOrigem, _, _) <- ruas, pOrigem == pontoAtual ]

-- SISTEMA DE RECOMPENSAS E PENALIDADES
bonusDestino :: Int
bonusDestino = 100

getReward :: Ponto -> Ponto -> Maybe Int
getReward a b =
    case custoRua a b of
        Nothing -> Nothing
        Just custo ->
            let penalidade = negate custo
                bonus = if b == destino
                        then bonusDestino
                        else 0
            in Just (penalidade + bonus)

-- ENCERRAMENTO DOS EPISODIOS

episodioTerminado :: Estado -> Bool
episodioTerminado estadoAtual =
    estadoAtual == destino
