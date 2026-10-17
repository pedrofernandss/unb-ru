# UnB RU — Grupo 09 — Sprint 1

Sistema de gerenciamento do Restaurante Universitário da UnB — Engenharia de Software, UnB, 2026.2.
**Sprint entregue:** Sprint 1 · **Fork:** [pedrofernandss/unb-ru](https://github.com/pedrofernandss/unb-ru) · **Release:** [v1.0.0](https://github.com/pedrofernandss/unb-ru/releases/tag/v1.0.0)

| Integrante | Matrícula | GitHub |
|---|---|---|
| Arthur Fernandes Vargas | 231013171 | `⟨A PREENCHER⟩` |
| Davi Dias da Silva Cruz | 180063251 | [@DaviDias21](https://github.com/DaviDias21) |
| Hendrick Henrique Moreno Quevedo | 231025510 | [@Hendrickhmq](https://github.com/Hendrickhmq) |
| Lucas Adeodato de Oliveira | 231013645 | [@HimeakLucas](https://github.com/HimeakLucas) |
| Pedro Fernandes de Oliveira | 231006177 | [@pedrofernandss](https://github.com/pedrofernandss) |

> ⚠️ Os campos marcados como `⟨A PREENCHER⟩` ainda aguardam o integrante responsável.

## 1. Scrum Master e Product Owner

| Papel | Responsável |
|---|---|
| **Scrum Master** | Arthur Fernandes Vargas |
| **Product Owner** | Pedro Fernandes de Oliveira |

O **Product Owner** definiu o escopo da sprint: traduziu as histórias do repositório principal para as 16 issues do fork, classificou-as entre `MVP` e `BONUS` e distribuiu a responsabilidade por cada uma. O **Scrum Master** conduziu o processo: organização do fluxo de trabalho, acompanhamento dos prazos e articulação entre os integrantes. Por ser papel de condução, não lhe são atribuídos pontos de backlog.

## 2. Funcionalidades e regras de negócio

Três perfis de usuário: o **estudante** (aplicativo), o **funcionário** (Aplicação de Controle, junto à catraca) e o **administrador** (configuração e auditoria). As 16 histórias seguem o padrão Connextra e estão registradas como issues no fork.

### Estudante

**#1 — Cadastro de Usuário** `MVP`
- Exige Nome Completo, Matrícula (SIGAA ou SIAPE), Senha e Confirmação.
- Senha e confirmação precisam ser idênticas; se divergirem, a conta não é criada.
- A matrícula identifica o usuário e é o que ele usa para entrar.

**#2 — Recarga de Saldo** `MVP`
- Recarga por pacote fechado ou quantidade personalizada, de **1 a 50 refeições**; fora da faixa, recusada.
- Tarifa unitária de **R$ 4,50**. Métodos: PIX Instantâneo e Cartão de Crédito.
- O saldo só é creditado **após aprovação do provedor de pagamento**; recusa não altera o saldo.

**#3 — Extrato e Histórico**
- Três indicadores consolidados: total gasto no mês, refeições realizadas e total recarregado.
- Tabela com Data e Hora, Refeição/Evento, Restaurante, Método de Acesso, Valor e Comprovante.
- Débitos em negativo, no formato brasileiro (`-R$ 4,50`).
- Estudante sem lançamentos vê a estrutura zerada, nunca uma tela de erro.

**#10 — Cardápio da Refeição Atual**
- Havendo refeição em serviço, informa **qual** é (café da manhã, almoço ou jantar) e exibe as três opções: padrão, ovolactovegetariano e vegetariano estrito.
- Fora dos horários de serviço, exibe aviso em vez de tela vazia.

**#11 — Exportação em PDF do Histórico**
- Exporta o **período filtrado** no extrato, em arquivo com cabeçalho identificando o relatório.
- Período sem lançamentos: avisa e **não gera arquivo** — nada de PDF vazio.

**#13 — Inscrição Única no FastPass** `BONUS`
- Inscrição **gratuita**, em **um único time-frame por turno**.
- Havendo inscrição ativa no turno, uma nova é recusada: é preciso cancelar a atual para trocar.

**#14 — Notificação de Sorteio** `BONUS`
- O resultado é divulgado **pelo menos 1 hora antes** do início da refeição.
- Antes dessa janela, o estudante recebe aviso de que o sorteio ainda não ocorreu, em vez de resultado em branco.

### Funcionário do restaurante

**#4 — Autenticação do Funcionário** `MVP`
- Autenticação por matrícula e senha.
- Credenciais inválidas mantêm o usuário no login, e a mensagem **não revela** qual campo falhou.

**#5 — Configuração de Ponto de Acesso**
- Logo após o login, o funcionário escolhe a unidade operacional e a catraca que vai operar.
- Somente catracas **online** podem ser operadas.
- O vínculo da sessão determina **onde os acessos serão registrados**.

**#6 — Validação de Entrada** `MVP`
- A verificação de saldo acontece **antes** da liberação: ninguém passa sem crédito.
- Com saldo, debita o valor e libera; sem saldo, bloqueia e não debita.
- O débito ocorre **no momento da passagem**.

**#7 — Histórico Local da Catraca**
- Mostra **apenas os acessos da catraca vinculada à sessão** — escopo local, distinto do relatório global (#9).
- Registra acessos liberados **e bloqueados**, com o motivo do bloqueio: a finalidade é auditoria.
- Funcionário sem catraca vinculada vê um aviso, não uma tabela.

**#15 — Validação Rigorosa do FastPass** `BONUS`
- A janela sorteada é **exata, sem tolerância**: leitura um segundo após o fim já é bloqueada.
- Mesmo dentro da janela, saldo insuficiente bloqueia e não debita.
- Só com as duas condições satisfeitas a catraca é liberada e a tarifa debitada.

### Administrador

**#8 — Gestão de Restaurantes e Catracas** `MVP`
- Restrita a administradores.
- Restaurante exige nome **único** e número de pisos numérico maior que zero.
- Catraca exige nome único **dentro do restaurante** e piso entre 1 e o número de pisos da unidade.
- Restaurante com catracas associadas **não pode ser removido**.

**#9 — Relatório Global de Acessos**
- Restrita a administradores. Abrange todos os acessos do campus, com filtros por restaurante, catraca e período.
- Consolida por restaurante: acessos liberados e arrecadação.
- **Somente acessos liberados** entram nos totais; bloqueados aparecem na listagem sem somar valor.
- A data inicial precisa ser anterior à final; período sem acessos exibe aviso.

**#12 — Exportação em PDF do Relatório**
- Reflete os **filtros aplicados** no momento da exportação.
- Sem acessos no período: avisa e não gera arquivo, mesma regra da #11.

**#16 — Gestão de Turnos e Time-Frames** `BONUS`
- Restrita a administradores. Cada turno tem início e fim, com fim posterior ao início.
- **Turnos não podem se sobrepor.**
- O turno é dividido em time-frames por uma **granularidade em minutos** — almoço das 11:15 às 14:15 com granularidade 15 gera 12 janelas.
- Os time-frames gerados são as janelas oferecidas no sorteio (#13).

## 3. Responsáveis, pontuação e Velocity

Pontos em escala **Fibonacci** (1, 2, 3, 5, 8), medindo complexidade relativa — número de regras e validações, criticidade do caminho triste e dependência de outras histórias —, não tempo de trabalho.

| # | Funcionalidade | Responsável | Prioridade | Pontos | Situação |
|---|---|---|---|---:|:---:|
| 1 | Cadastro de Usuário | [@pedrofernandss](https://github.com/pedrofernandss) | MVP | 3 | ✅ |
| 2 | Recarga de Saldo | [@Hendrickhmq](https://github.com/Hendrickhmq) | MVP | 5 | ✅ |
| 3 | Extrato e Histórico | [@pedrofernandss](https://github.com/pedrofernandss) | — | 5 | ✅ |
| 4 | Autenticação do Funcionário | [@pedrofernandss](https://github.com/pedrofernandss) | MVP | 3 | ✅ |
| 5 | Configuração de Ponto de Acesso | [@Hendrickhmq](https://github.com/Hendrickhmq) | — | 3 | ✅ |
| 6 | Validação de Entrada | [@DaviDias21](https://github.com/DaviDias21) | MVP | 5 | ✅ |
| 7 | Histórico Local da Catraca | [@DaviDias21](https://github.com/DaviDias21) | — | 2 | ✅ |
| 8 | Gestão de Restaurantes e Catracas | [@HimeakLucas](https://github.com/HimeakLucas) | MVP | 8 | ✅ |
| 9 | Relatório Global de Acessos | [@HimeakLucas](https://github.com/HimeakLucas) | — | 8 | ✅ |
| 10 | Cardápio da Refeição Atual | [@DaviDias21](https://github.com/DaviDias21) | — | 3 | ✅ |
| 11 | Exportação em PDF do Histórico | [@Hendrickhmq](https://github.com/Hendrickhmq) | — | 3 | ✅ |
| 12 | Exportação em PDF do Relatório | [@HimeakLucas](https://github.com/HimeakLucas) | — | 2 | ✅ |
| 13 | Inscrição Única no FastPass | [@pedrofernandss](https://github.com/pedrofernandss) | BONUS | 5 | ✅ |
| 14 | Notificação de Sorteio | [@DaviDias21](https://github.com/DaviDias21) | BONUS | 3 | ✅ |
| 15 | Validação Rigorosa FastPass | [@Hendrickhmq](https://github.com/Hendrickhmq) | BONUS | 5 | ✅ |
| 16 | Gestão de Turnos e Time-Frames | [@HimeakLucas](https://github.com/HimeakLucas) | BONUS | 8 | ✅ |

**Velocity = 71 de 71 pontos (100%).** As 16 histórias foram especificadas e integradas à `sprint-01`, sem saldo de backlog para a próxima sprint. Por integrante: Lucas 26, Pedro 16, Hendrick 16, Davi 13, Arthur 0 (papel de condução, sem histórias de backlog).

"Entregue" refere-se ao escopo desta sprint — a especificação dos cenários BDD em Cucumber. São **15 features e 52 cenários**, todas com ao menos um caminho feliz e um triste, como exige a especificação da disciplina. A implementação ocorre nas sprints seguintes.

## 4. Padrão de commits, branching e revisão

**Commits.** [Conventional Commits](https://www.conventionalcommits.org/), no formato `<tipo>: <descrição no imperativo>`, usando `feat`, `fix`, `test`, `refactor`, `docs` e `chore`.

**Branching.** Três níveis: `main` recebe apenas o resultado consolidado de uma sprint encerrada; `sprint-01` concentra o trabalho da sprint e é a base dos PRs individuais; cada integrante trabalha em `feat/<escopo>` ou `fix/<escopo>`. Ao final, o grupo gera uma **tag de release** e abre um PR de `sprint-01` para a `main` do repositório principal, com o título `Grupo 09 - Sprint 1` e o nome e matrícula dos integrantes no comentário.

**Revisão.** Todo PR tem como destino a `sprint-01` e **nenhum integrante aprova o próprio**. O revisor confere a cobertura de caminho feliz e triste, se as regras de negócio assumidas estão explicitadas na descrição e se os commits seguem o padrão. O merge só ocorre após aprovação.

> **Observação de transparência.** A aderência evoluiu ao longo da sprint: parte dos commits iniciais foi enviada direto para a `sprint-01`, sem branch nem PR, e algumas mensagens desse período não seguem Conventional Commits. A segunda metade seguiu o fluxo completo — os PRs #18, #19 e #20 foram revisados antes de integrados, e o #20 exemplifica a política funcionando, já que a revisão apontou um arquivo de feature sem cenários e o merge só ocorreu após as correções. A exceção foi o PR #17, integrado pelo próprio autor sem revisão. A revisão por terceiro passa a ser condição obrigatória de merge a partir da Sprint 2.

## 5. Uso de Inteligência Artificial

A disciplina permite o uso de IA, mas exige que cada integrante declare a ferramenta, a parte do projeto e a estratégia. Uso não justificado, ou que o aluno não saiba explicar, reduz a nota. **Quem não usou IA deve declarar isso explicitamente.**

**Hendrick Henrique Moreno Quevedo** — Claude (Anthropic), via Claude Code. Usado na preparação do ambiente de desenvolvimento, na especificação dos cenários BDD das histórias #2, #5, #11 e #15 com seus step definitions, e na redação desta página.
*Estratégia:* o protótipo do Figma foi lido antes da escrita de cada `.feature`, para que os rótulos de campos, botões e mensagens fossem os da interface projetada e não inventados; os step definitions existentes foram reaproveitados, evitando ambiguidade; cada feature recebeu ao menos um caminho feliz e um triste, conforme a taxonomia da disciplina; e `cucumber --dry-run` e RuboCop foram executados a cada alteração. O material gerado foi revisado e redirecionado: a primeira versão trazia 22 cenários e foi reduzida a 10 para ficar coerente com o volume dos demais integrantes, a divergência entre os models dos PRs #17 e #18 foi identificada e corrigida por um commit de refactor, e as regras de negócio assumidas foram registradas na descrição do PR em vez de embutidas silenciosamente nos cenários.

**Pedro Fernandes de Oliveira** — `⟨A PREENCHER⟩`

**Davi Dias da Silva Cruz** — `⟨A PREENCHER⟩`

**Lucas Adeodato de Oliveira** — `⟨A PREENCHER⟩`

**Arthur Fernandes Vargas** — `⟨A PREENCHER⟩`

## 6. Pontos em aberto para a Sprint 2

- **Unificar o modelo de dados.** As histórias foram especificadas em paralelo e os cenários assumiram modelos incompatíveis, hoje convivendo na `sprint-01`: a `Catraca` aparece como `(nome, piso)` numérico, como `(identificacao, online)` e com piso em texto; e o registro de acesso aparece como `Acesso`, `AcessoCatraca`, `Lancamento` e `Transaction`. Unificar isso é o primeiro trabalho do modelo entidade-relacionamento.
- **Decidir a regra de tolerância do FastPass.** A #16 prevê um campo de tolerância de atraso, enquanto os cenários da #15 adotam janela exata, seguindo o protótipo do Figma.
- **Corrigir a integração contínua.** O workflow falha em todas as branches por motivos estruturais: não existe `db/schema.rb`, porque o projeto ainda não tem migrations, e há ofensas de RuboCop em `config/application.rb`, herdadas do commit inicial.
