module Environment where

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
    case [custo | (origemRua, destinoRua, custo) <- ruas,
                  origemRua == a,
                  destinoRua == b] of
        [] -> Nothing
        (c:_) -> Just c


-- MOVIMENTACAO DO AGENTE

type Estado = Ponto

-- Identifica as opcoes de deslocamento
opcoesDeslocamento :: Ponto -> [Rua]
opcoesDeslocamento pontoAtual =
    [rua | rua@(pOrigem, _, _) <- ruas,
           pOrigem == pontoAtual]

-- Escolhe uma rua disponivel
escolherRua :: [Rua] -> Int -> Maybe Rua
escolherRua [] _ = Nothing
escolherRua opcoes idx =
    let indiceSeguro = idx `mod` length opcoes
    in Just (opcoes !! indiceSeguro)

-- Realiza a mudanca de estado
moverEstado :: Estado -> Rua -> Estado
moverEstado _ (_, pDestino, _) = pDestino

-- Realiza um passo completo
moverNoMapa :: Estado -> Int -> Estado
moverNoMapa estadoAtual idx =
    case escolherRua (opcoesDeslocamento estadoAtual) idx of
        Nothing  -> estadoAtual
        Just rua -> moverEstado estadoAtual rua
