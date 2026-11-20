module Environment where

{-
Integrante 2 — Movimentação do agente
Arquivo: Environment.hs

Tarefas:
- Implementar a lógica de movimentação do entregador.
- Criar a função que identifica os caminhos disponíveis a partir de determinado ponto.
- Permitir que o agente escolha uma rua disponível.
- Implementar a transição de um estado para outro.

Entrega esperada: movimentação funcional, permitindo que o agente percorra o mapa seguindo as conexões disponíveis.

Para apresentação: explicar como o agente identifica as opções de deslocamento e como acontece a mudança entre estados.
-}

-- =========================================================================
-- 1. TIPOS BASEADOS EM CHAR (ALINHAR COM A INTEGRANTE 1 QUANDO ELA SUBIR)
-- =========================================================================
-- Os pontos da cidade (A, B, C, D, E e F) são representados como Char.
type Ponto = Char
type Estado = Ponto
type Custo = Double

-- [AJUSTAR COM INTEGRANTE 1]
-- Confira se o tipo/construtor de rua e mapa da Integrante 1 usam estes campos
-- ou se será necessário adaptar o nome do tipo e das funções de acesso.
data Rua = Rua
  { origem  :: Ponto
  , destino :: Ponto
  , custo   :: Custo
  } deriving (Show, Eq)

type Mapa = [Rua]


-- =========================================================================
-- 2. IDENTIFICAR OPCOES DE DESLOCAMENTO
-- =========================================================================
-- Dado o mapa e o estado/ponto atual ('A'..'F'), retorna as ruas que saem dali.
opcoesDeslocamento :: Mapa -> Estado -> [Rua]
opcoesDeslocamento mapa estadoAtual =
  filter (\rua -> origem rua == estadoAtual) mapa


-- =========================================================================
-- 3. ESCOLHER UMA RUA DISPONIVEL
-- =========================================================================
-- Recebe as ruas disponíveis e um índice (ex.: 0, 1, ...).
-- Usa 'mod' para garantir que o índice fique dentro do tamanho da lista.
-- Retorna Nothing se não houver ruas disponíveis no ponto atual.
escolherRua :: [Rua] -> Int -> Maybe Rua
escolherRua [] _ = Nothing
escolherRua opcoes idx =
  let indiceSeguro = idx `mod` length opcoes
  in Just (opcoes !! indiceSeguro)


-- =========================================================================
-- 4. TRANSICAO DE ESTADO (MUDANCA DE PONTO)
-- =========================================================================
-- Recebe o estado atual (Char) e a rua escolhida, devolvendo o novo estado (Char).
moverEstado :: Estado -> Rua -> Estado
moverEstado _estadoAtual ruaEscolhida = destino ruaEscolhida


-- =========================================================================
-- 5. PASSO COMPLETO DE MOVIMENTACAO (AUXILIAR)
-- =========================================================================
-- Combina busca das opções, escolha segura e mudança de estado.
-- Se não houver rua disponível, permanece no estado atual.
moverNoMapa :: Mapa -> Estado -> Int -> Estado
moverNoMapa mapa estadoAtual idx =
  case escolherRua (opcoesDeslocamento mapa estadoAtual) idx of
    Nothing  -> estadoAtual
    Just rua -> moverEstado estadoAtual rua