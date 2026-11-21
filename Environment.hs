module Environment
    ( Estado
    , episodioTerminado
    , opcoesDeslocamento
    , ruas
    , getReward
    , origem
    ) where

-- Representa um ponto da cidade
type Ponto = String

-- Representa uma rua (origem, destino, custo)
type Rua = (Ponto, Ponto, Int)

-- Pontos existentes na cidade
pontos :: [Ponto]
pontos = ["A", "B", "C", "D", "E", "F"]

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

-- 2. Escolher uma rua disponível:
-- Recebe a lista de opções e um índice (ex.: 0, 1, ...).
-- Usa 'mod' para manter o índice dentro da lista e retorna Nothing se não houver opções.
escolherRua :: [Rua] -> Int -> Maybe Rua
escolherRua [] _ = Nothing
escolherRua opcoes idx =
    let indiceSeguro = idx `mod` length opcoes
    in Just (opcoes !! indiceSeguro)

-- 3. Mudança de estado:
-- Dado o estado atual e a rua escolhida, retorna o novo estado (ponto de destino).
moverEstado :: Estado -> Rua -> Estado
moverEstado _estadoAtual (_, pDestino, _) = pDestino

-- 4. Auxiliar de um passo completo:
-- Busca as opções a partir do ponto atual, escolhe uma e avança para o próximo ponto.
moverNoMapa :: Estado -> Int -> Estado
moverNoMapa estadoAtual idx =
    case escolherRua (opcoesDeslocamento estadoAtual) idx of
        Nothing  -> estadoAtual
        Just rua -> moverEstado estadoAtual rua

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