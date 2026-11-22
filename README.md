# Q-Learning em Haskell – Agente de Entregas

Projeto prático que utiliza **Q-Learning**, um algoritmo de Aprendizado por Reforço, para que um agente (um entregador) aprenda sozinho a melhor rota em uma pequena cidade fictícia, a partir de tentativas, recompensas e penalidades.

**Autores:** Eduardo Miguel, Ellen Ozores, Kauã Santana, Mel Yukari, Waleska Mayara e Philip Micael.

---

## 1. Objetivo

O entregador parte do ponto **A** e precisa chegar ao ponto **F**. O mapa possui seis pontos conectados por ruas com custos diferentes. O objetivo é que o agente descubra, por meio do treinamento, qual caminho tem o **menor custo total**.

A rota final **não está definida no código**: ela é construída a partir dos valores aprendidos na tabela Q.

### Mapa e custos (dados usados)

| Origem | Destino | Custo |
|--------|---------|-------|
| A | B | 2 |
| A | C | 4 |
| B | D | 2 |
| B | E | 5 |
| C | D | 2 |
| C | E | 2 |
| D | F | 4 |
| E | F | 1 |

```
        2         2
   ┌──── B ──────── D ──┐
   │     │ 5        │ 2 │ 4
   A     │          │   F
   │     ▼          │   ▲
   └──── C ─────────┘   │
        4 └──── E ──────┘
             2      1
```

(Diagrama simplificado; as ligações exatas estão na tabela acima. Todas as ruas têm mão única, da origem para o destino.)

| Rota | Custo total |
|------|-------------|
| A → B → D → F | 8 |
| A → B → E → F | 8 |
| A → C → D → F | 10 |
| **A → C → E → F** | **7** (melhor) |

---

## 2. Como o Q-Learning foi aplicado

| Elemento | Aplicação no projeto |
|----------|----------------------|
| Agente | Entregador que precisa encontrar uma rota |
| Ambiente | Mapa da cidade (`Environment.hs`) |
| Estados | Pontos A, B, C, D, E e F |
| Ações | Escolher uma rua que sai do ponto atual (a ação é representada pelo ponto de destino) |
| Recompensa | `-custo` da rua percorrida, mais um bônus de `+100` ao chegar em F |
| Tabela Q | `Map (Estado, Acao) Double` com o valor aprendido de cada decisão |

### Funcionamento

O treinamento é dividido em **episódios**. Em cada episódio:

1. O agente começa no ponto A.
2. Escolhe uma rua usando a estratégia **Epsilon-Greedy**: com probabilidade `epsilon` explora uma rua aleatória; caso contrário, escolhe a rua de maior valor Q.
3. Recebe a recompensa (penalidade pelo custo, mais o bônus se chegou em F).
4. Atualiza a tabela Q com a equação do Q-Learning:

   ```
   Q(s, a) ← Q(s, a) + α · ( r + γ · max Q(s', a') − Q(s, a) )
   ```

5. Repete até chegar em F ou atingir o limite de movimentos por episódio.

Ao final, a rota é construída seguindo sempre a **melhor ação** de cada estado (a de maior valor Q), partindo de A até F.

O sorteio do Epsilon-Greedy usa um gerador congruencial linear próprio (semente fixa), sem dependências externas, então os resultados são **reproduzíveis** a cada execução.

### Parâmetros de treinamento

Valores padrão (`configPadrao`, em `QLearning.hs`) e os valores efetivamente usados em `app/Main.hs`:

| Parâmetro | Padrão | Usado no `Main` |
|-----------|--------|-----------------|
| Episódios | 1000 | **5000** |
| Taxa de aprendizado (α) | 0,1 | 0,1 |
| Fator de desconto (γ) | 0,9 | **1,0** |
| Epsilon (ε) | 0,3 | **0,2** |
| Máximo de movimentos por episódio | 20 | 20 |
| Semente do gerador aleatório | – | 42 |

Para alterar esses valores, edite o bloco `config` em `app/Main.hs`.

---

## 3. Estrutura do projeto

```
q-learning/
├── app/
│   └── Main.hs          # Executa o treinamento, monta a rota aprendida e exibe o resultado
├── src/
│   ├── Environment.hs   # Mapa, ruas, movimentação, custos, recompensas e fim do episódio
│   ├── QLearning.hs     # Tabela Q, atualização, Epsilon-Greedy e treinamento
│   └── Printing.hs      # Funções de impressão no terminal
├── package.yaml         # Configuração do projeto (hpack)
├── q-learning.cabal     # Gerado automaticamente a partir do package.yaml
├── stack.yaml           # Configuração do Stack (snapshot LTS 24.67)
├── flake.nix            # Ambiente de desenvolvimento reproduzível com Nix
└── README.md
```

### Responsabilidade de cada módulo

- **`Environment.hs`**: define pontos, ruas e custos; `opcoesDeslocamento` lista as ruas que saem de um ponto; `getReward` calcula a recompensa (`-custo` + bônus no destino); `episodioTerminado` indica se o agente chegou em F.
- **`QLearning.hs`**: `inicializarTabela`, `atualizarQ`, `escolherAcao` (Epsilon-Greedy), `melhorAcao`, `executarEpisodio` e `treinar`.
- **`Printing.hs`**: exibe configuração, tabela Q, rota escolhida, mapa com a rota destacada e recompensas por deslocamento.
- **`Main.hs`**: treina o agente e constrói a rota final (`rotaAprendida`) a partir da tabela Q.

---

## 4. Arquivos necessários para compilar e executar

| Arquivo | Função |
|---------|--------|
| `package.yaml` | Define nome, dependências (`base`, `containers`), módulos e executável |
| `q-learning.cabal` | Descrição do pacote para o Cabal (gerado pelo `hpack`) |
| `stack.yaml` | Define o snapshot do Stackage (`lts-24.67`, GHC 9.10.x) |
| `flake.nix` | Ambiente Nix com GHC 9.10, Cabal, HLS, HLint e hpack |
| `src/*.hs` e `app/Main.hs` | Código-fonte |

**Dependências:** `base` (>= 4.7 e < 5) e `containers` (usada para `Data.Map`). Não há bibliotecas externas além das que acompanham o GHC.

---

## 5. Instruções de execução

Escolha **uma** das opções abaixo.

### Opção A – Stack

Requisito: [Stack](https://docs.haskellstack.org/) instalado.

```bash
git clone <url-do-repositorio>
cd q-learning

stack build
stack run
```

O Stack baixa automaticamente o GHC do snapshot configurado e gera o `.cabal` a partir do `package.yaml`.

### Opção B – Nix + Cabal

Requisito: [Nix](https://nixos.org/) com flakes habilitados.

```bash
cd q-learning

nix develop          # entra no ambiente com GHC, cabal-install, hpack, HLS e HLint
hpack                # gera/atualiza o q-learning.cabal a partir do package.yaml
cabal run q-learning-exe
```

### Opção C – GHC/Cabal já instalados

Requisitos: GHC 9.10 (ou compatível) e `cabal-install`. Ambos podem ser instalados pelo GHCup, seguindo as instruções em <https://www.haskell.org/downloads/>.

```bash
cabal run q-learning-exe
```

> Se o `q-learning.cabal` estiver desatualizado em relação ao `package.yaml`, execute `hpack` antes.

---

## 6. Saída esperada

O programa roda pelo terminal (sem interface gráfica) e imprime:

- as configurações do treinamento (episódios, epsilon e gamma);
- a tabela Q aprendida;
- a rota escolhida pelo agente;
- o mapa de ruas, com a rota aprendida destacada por `==>`;
- a recompensa de cada deslocamento, com o valor Q correspondente;
- a recompensa total da rota.

Com o treinamento convergido, espera-se que o agente escolha a rota **A → C → E → F**, que é a de menor custo (7).

Como a recompensa é `-custo` mais `+100` ao chegar no destino, a recompensa total dessa rota é `-4 -2 -1 + 100 = 93`.

Valores de Q para os quais a tabela tende a convergir (com γ = 1,0), úteis para conferir o aprendizado:

| Estado → Ação | Q aproximado |
|---------------|--------------|
| E → F | 99 |
| C → E | 97 |
| **A → C** | **93** |
| D → F | 96 |
| C → D | 94 |
| B → D | 94 |
| B → E | 94 |
| A → B | 92 |

Como `Q(A→C) > Q(A→B)`, o agente escolhe A → C no início da rota, e em seguida `Q(C→E) > Q(C→D)` o leva a E e depois a F.

---

## 7. Possível aplicação em testes de software

O mesmo princípio pode ser adaptado para gerar casos de teste automaticamente:

- **Estado:** tela ou situação atual do sistema.
- **Ação:** clicar em um botão, preencher um campo ou navegar.
- **Recompensa:** encontrar um comportamento novo, aumentar a cobertura de testes ou identificar um erro.

Assim, o agente poderia aprender sequências de ações que exploram diferentes caminhos de execução de um software. Esta aplicação é apresentada apenas como uma possibilidade de uso do Q-Learning e **não** está implementada neste projeto.