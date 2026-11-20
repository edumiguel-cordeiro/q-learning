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