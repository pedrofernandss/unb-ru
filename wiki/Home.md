# UnB RU — Grupo 09 — Sprint 1

Sistema de gerenciamento do Restaurante Universitário da UnB.
Disciplina de Engenharia de Software — Universidade de Brasília — 2026.2

> ⚠️ **Esta página ainda tem campos pendentes.** Todo trecho marcado como `⟨A PREENCHER⟩` precisa ser completado pelo integrante responsável antes da avaliação final.

**Sprint entregue:** Sprint 1 (primeira etapa — 16/10/2026)
**Repositório principal:** [neatzzy/UnB_RU](https://github.com/neatzzy/UnB_RU) · **Fork do grupo:** [pedrofernandss/unb-ru](https://github.com/pedrofernandss/unb-ru)

## Integrantes

| Nome completo | Matrícula | GitHub |
|---|---|---|
| Arthur Fernandes Vargas | 231013171 | `⟨A PREENCHER⟩` |
| Davi Dias da Silva Cruz | 180063251 | [@DaviDias21](https://github.com/DaviDias21) |
| Hendrick Henrique Moreno Quevedo | 231025510 | [@Hendrickhmq](https://github.com/Hendrickhmq) |
| Lucas Adeodato de Oliveira | 231013645 | [@HimeakLucas](https://github.com/HimeakLucas) |
| Pedro Fernandes de Oliveira | 231006177 | [@pedrofernandss](https://github.com/pedrofernandss) |

**Monitores:** Élvis Corrêa Miranda Júnior ([@neatzzy](https://github.com/neatzzy)) e Rafael Medeiros ([@leitaonerd](https://github.com/leitaonerd)) — ambos já incluídos como colaboradores do fork.

---

## 1. Scrum Master e Product Owner

| Papel | Responsável |
|---|---|
| **Scrum Master** | Arthur Fernandes Vargas |
| **Product Owner** | Pedro Fernandes de Oliveira |

Coube ao **Product Owner** traduzir as histórias de usuário do repositório principal para as 16 issues do fork, classificá-las entre `MVP` e `BONUS` conforme a prioridade de entrega e distribuir a responsabilidade por cada uma entre os integrantes — definindo, na prática, o escopo e a ordem de ataque do backlog desta sprint.

Coube ao **Scrum Master** a coordenação do grupo ao longo da sprint: organização do fluxo de trabalho, acompanhamento dos prazos das duas etapas da entrega e articulação entre os integrantes para que as histórias distribuídas avançassem em paralelo. Por ser um papel de condução do processo, e não de especificação de histórias, não lhe são atribuídos pontos de backlog (ver seção 5).

---

## 2. Funcionalidades e regras de negócio

O sistema tem **três perfis de usuário**: o **estudante** (usa o aplicativo), o **funcionário** do restaurante (opera a Aplicação de Controle junto à catraca) e o **administrador** (configura a operação e audita o campus).

As 16 histórias de usuário foram escritas no padrão Connextra e estão registradas como issues no fork. As de maior prioridade estão marcadas como `MVP` e as complementares como `BONUS`.

### Estudante

#### #1 — Cadastro de Usuário `MVP`

> Como estudante, eu quero me cadastrar no sistema utilizando minha matrícula, para que eu possa criar minha conta de acesso ao RU.

- O cadastro exige Nome Completo, Matrícula (SIGAA ou SIAPE), Senha de Acesso e Confirmar Senha.
- A senha e a confirmação precisam ser idênticas; se divergirem, a conta não é criada.
- A matrícula é o identificador do usuário no sistema e é o que ele usa depois para entrar.
- Cadastro concluído com sucesso redireciona para a página de login.

#### #2 — Recarga de Saldo `MVP`

> Como estudante, eu quero adicionar créditos à minha conta via PIX ou cartão de crédito, para que eu tenha saldo suficiente para acessar os restaurantes.

- A recarga pode ser feita por pacote fechado (ex.: 5 ou 10 refeições) ou por quantidade personalizada.
- A quantidade personalizada aceita de **1 a 50 refeições**; fora dessa faixa a recarga é recusada e o saldo não muda.
- A tarifa unitária da refeição é de **R$ 4,50** — um pacote de 5 refeições custa R$ 22,50.
- Métodos de pagamento aceitos: **PIX Instantâneo** e **Cartão de Crédito**.
- O saldo só é creditado **após a aprovação do provedor de pagamento**. Se o provedor recusar a transação, o saldo permanece exatamente como estava.

#### #3 — Extrato e Histórico

> Como estudante, eu quero visualizar meu extrato de recargas e histórico de refeições, para ter controle sobre meus gastos e utilizações.

- A página de extrato apresenta três indicadores consolidados: **total gasto no mês**, **total de refeições realizadas** e **total recarregado**.
- A tabela de lançamentos traz Data e Hora, Refeição/Evento, Restaurante, Método de Acesso, Valor e Comprovante.
- Débitos são exibidos com sinal negativo e no formato monetário brasileiro (ex.: `-R$ 4,50`).
- Um estudante recém-cadastrado, sem nenhum lançamento, vê a mesma estrutura com os indicadores zerados e a tabela vazia — nunca uma tela de erro.

#### #10 — Cardápio da Refeição Atual

> Como estudante, eu quero poder ver o cardápio da refeição que esteja sendo servida agora, incluindo as opções padrão, ovolactovegetariano e vegetariano estrito.

- A página inicial tem a seção "Cardápio" com o botão "Atualizar Cardápio".
- Havendo refeição em serviço, o sistema informa **qual** refeição é (café da manhã, almoço ou jantar) e exibe as **três opções**: padrão, ovolactovegetariano e vegetariano estrito.
- Fora dos horários de serviço não há cardápio a exibir, e o estudante recebe um aviso em vez de uma tela em branco.

#### #11 — Exportação em PDF do Histórico

> Eu, como estudante, quero poder exportar meu Extrato e Histórico de Refeições como PDF para poder controlar melhor as minhas finanças.

- A exportação respeita o **período filtrado** na tela de extrato.
- O arquivo gerado chama-se `extrato-refeicoes.pdf` e traz o cabeçalho "Extrato e Histórico de Refeições".
- Se o período selecionado não tiver nenhum lançamento, o sistema **avisa e não gera arquivo** — a regra é não produzir um PDF vazio.

#### #13 — Inscrição Única no FastPass `BONUS`

> Como estudante, eu quero me inscrever no sorteio gratuito do FastPass escolhendo apenas um time-frame por turno de refeição, para tentar garantir meu acesso sem filas.

- A inscrição no sorteio é **gratuita**.
- O estudante escolhe **um único time-frame por turno** de refeição.
- Existindo inscrição ativa para aquele turno, uma nova inscrição é recusada: é preciso **cancelar a atual** para trocar de horário.
- Confirmada a inscrição, o turno passa a exibir o status de inscrito com a janela escolhida.

#### #14 — Notificação de Sorteio `BONUS`

> Como estudante, eu quero ser notificado se ganhei ou não o FastPass 1 hora antes do turno, para que eu possa planejar meu horário de ida ao RU.

- O sorteio é encerrado e o resultado divulgado **pelo menos 1 hora antes** do início da refeição, para que o estudante tenha tempo de planejar a ida ao RU.
- Dentro dessa janela de uma hora, o estudante consulta o resultado — **ganhou ou não ganhou**.
- Antes da janela, o resultado ainda não existe: o estudante recebe um aviso de que o sorteio não aconteceu e deve voltar mais tarde, em vez de uma tela vazia ou de um resultado em branco.

### Funcionário do restaurante

#### #4 — Autenticação do Funcionário `MVP`

> Como funcionário do restaurante, eu quero fazer login na aplicação de controle, para autenticar minha sessão e operar o sistema de forma segura.

- A autenticação é feita por **matrícula e senha**.
- Credenciais inválidas mantêm o usuário na tela de login e exibem mensagem de erro.
- Por segurança, a mensagem de erro **não revela** se o que falhou foi a matrícula ou a senha.
- Autenticado, o usuário é levado à página inicial.

#### #5 — Configuração de Ponto de Acesso

> Como funcionário do restaurante, logo após o login, eu quero selecionar em qual restaurante vou gerenciar, para que o sistema direcione as regras corretamente e grave os logs corretamente.

- Logo após o login, o funcionário escolhe a **unidade operacional** e, dentro dela, a **catraca física** que vai operar.
- Somente catracas **online** podem ser operadas: ao tentar vincular-se a uma catraca offline, a sessão não é vinculada e o sistema explica o motivo.
- Confirmada a seleção, a sessão do funcionário fica **vinculada àquela catraca** e ele é direcionado ao terminal de validação.
- Esse vínculo é o que determina **onde os acessos serão registrados** — é a origem dos logs de operação.

#### #6 — Validação de Entrada `MVP`

> Como aplicação de controle, eu quero ler a identificação do aluno, verificar se há saldo, enviar o comando de liberação para a catraca e efetuar o débito da refeição no momento da passagem.

- O terminal apresenta o painel "Catraca Atual" e a seção de leitura do QR Code.
- A verificação de saldo acontece **antes** da liberação: nenhum aluno passa sem ter crédito.
- Com saldo suficiente, o sistema **debita o valor da refeição e libera** a catraca.
- Com saldo insuficiente, o acesso é **bloqueado** e nada é debitado.
- O débito ocorre **no momento da passagem**, não antes.

#### #7 — Histórico Local da Catraca

> Como funcionário, eu quero visualizar na aplicação de controle o histórico de todos os acessos registrados apenas na catraca que estou gerenciando no momento, para realizar auditorias ou conferências locais de fluxo.

- O funcionário vê **apenas os acessos da catraca à qual sua sessão está vinculada** — um escopo local, distinto do relatório global do administrador (#9).
- A tela identifica qual catraca está sendo gerenciada e lista os acessos em uma tabela com Horário, Matrícula do discente, Modo de Validação, Tarifa e Status da Catraca.
- O histórico registra **tanto acessos liberados quanto bloqueados**, e o status informa o motivo do bloqueio (ex.: saldo insuficiente) — a finalidade é auditoria, então a tentativa recusada também precisa aparecer.
- Um funcionário que não esteja vinculado a nenhuma catraca não vê tabela alguma, e sim um aviso de que não está gerenciando nenhuma catraca no momento.

#### #15 — Validação Rigorosa do FastPass `BONUS`

> Como aplicação de controle, eu quero checar se o aluno sorteado para o Fastpass chegou no horário vigente. Se sim, comando a liberação da catraca física e debito o saldo; se não, bloqueio a entrada.

- Aplica-se ao estudante **sorteado** no FastPass, em uma sessão vinculada a uma catraca online.
- A janela sorteada é **exata, sem tolerância**: uma leitura um segundo após o fim do time-frame já é bloqueada.
- Mesmo **dentro** da janela, saldo insuficiente bloqueia a entrada e não debita.
- Só quando as duas condições são satisfeitas — dentro da janela **e** com saldo — a catraca é liberada e a tarifa é debitada.

### Administrador

#### #8 — Gestão de Restaurantes e Catracas `MVP`

> Como administrador, eu quero cadastrar, editar e remover diferentes restaurantes e suas respectivas catracas físicas no sistema, para que os funcionários possam selecioná-las na Aplicação de Controle.

- Funcionalidade **restrita a administradores**; outros perfis são redirecionados e avisados.
- Restaurante exige **Nome da Unidade** (obrigatório e **único** no sistema) e **Número de Pisos** (obrigatório, numérico e maior que zero).
- Catraca exige nome **único dentro do mesmo restaurante** e um **piso entre 1 e o número de pisos** daquele restaurante.
- Um restaurante que ainda **possui catracas associadas não pode ser removido** — é preciso remover as catracas antes, preservando a integridade dos registros de acesso.

#### #9 — Relatório Global de Acessos

> Como administrador, eu quero visualizar o histórico completo de todos os acessos do campus, podendo filtrar e agrupar os dados por restaurante e por catraca específica, para ter uma visão gerencial de toda a operação.

- Funcionalidade **restrita a administradores**.
- Abrange **todos os acessos do campus**, com filtros por restaurante, por catraca e por período.
- Apresenta consolidação **por restaurante**, com a quantidade de acessos liberados e a arrecadação de cada unidade.
- **Somente acessos liberados** entram nos totais de refeições servidas e de arrecadação; acessos bloqueados aparecem na listagem, mas não somam valor.
- A **data inicial precisa ser anterior à data final**; caso contrário o filtro é recusado.
- Um período sem acessos exibe um aviso em vez de uma tabela vazia sem explicação.

#### #12 — Exportação em PDF do Relatório de Operação

> Eu, como administrador geral do sistema, quero poder exportar o Relatório Global de Operação com finalidade de auditoria interna.

- A exportação reflete exatamente os **filtros aplicados** no relatório naquele momento.
- Sem acessos no período selecionado, o sistema **avisa e não gera arquivo** — mesma regra adotada na exportação do estudante (#11).

#### #16 — Gestão de Turnos e Time-Frames `BONUS`

> Como administrador, eu quero definir os horários dos turnos e dividi-los em time-frames configuráveis, para organizar a distribuição do FastPass.

- Funcionalidade **restrita a administradores**.
- Cada turno (Café da Manhã, Almoço e Jantar) tem horário de início e fim, com o **fim posterior ao início** e horários válidos no relógio de 24 horas.
- **Turnos não podem se sobrepor** entre si.
- O turno é dividido em time-frames a partir de uma **granularidade em minutos** — um almoço das 11:15 às 14:15 com granularidade de 15 minutos gera 12 janelas, da primeira (11:15–11:30) à última (14:00–14:15).
- Os time-frames gerados são as janelas oferecidas no sorteio do FastPass (#13).

---

## 3. Responsáveis por cada funcionalidade

| # | Funcionalidade | Responsável | Prioridade | Situação |
|---|---|---|---|---|
| 1 | Cadastro de Usuário | [@pedrofernandss](https://github.com/pedrofernandss) | MVP | ✅ Entregue |
| 2 | Recarga de Saldo | [@Hendrickhmq](https://github.com/Hendrickhmq) | MVP | ✅ Entregue |
| 3 | Extrato e Histórico | [@pedrofernandss](https://github.com/pedrofernandss) | — | ✅ Entregue |
| 4 | Autenticação do Funcionário | [@pedrofernandss](https://github.com/pedrofernandss) | MVP | ✅ Entregue |
| 5 | Configuração de Ponto de Acesso | [@Hendrickhmq](https://github.com/Hendrickhmq) | — | ✅ Entregue |
| 6 | Validação de Entrada | [@DaviDias21](https://github.com/DaviDias21) | MVP | ✅ Entregue |
| 7 | Histórico Local da Catraca | [@DaviDias21](https://github.com/DaviDias21) | — | ✅ Entregue |
| 8 | Gestão de Restaurantes e Catracas | [@HimeakLucas](https://github.com/HimeakLucas) | MVP | ✅ Entregue |
| 9 | Relatório Global de Acessos | [@HimeakLucas](https://github.com/HimeakLucas) | — | ✅ Entregue |
| 10 | Cardápio da Refeição Atual | [@DaviDias21](https://github.com/DaviDias21) | — | ✅ Entregue |
| 11 | Exportação em PDF do Histórico | [@Hendrickhmq](https://github.com/Hendrickhmq) | — | ✅ Entregue |
| 12 | Exportação em PDF do Relatório | [@HimeakLucas](https://github.com/HimeakLucas) | — | ✅ Entregue |
| 13 | Inscrição Única no FastPass | [@pedrofernandss](https://github.com/pedrofernandss) | BONUS | ✅ Entregue |
| 14 | Notificação de Sorteio | [@DaviDias21](https://github.com/DaviDias21) | BONUS | ✅ Entregue |
| 15 | Validação Rigorosa FastPass | [@Hendrickhmq](https://github.com/Hendrickhmq) | BONUS | ✅ Entregue |
| 16 | Gestão de Turnos e Time-Frames | [@HimeakLucas](https://github.com/HimeakLucas) | BONUS | ✅ Entregue |

"Entregue" refere-se ao escopo desta sprint: a **especificação dos cenários BDD** da história em Cucumber. A implementação das funcionalidades acontece nas sprints seguintes.

---

## 4. Padrão de commits, branching e revisão

### Padrão de commits

O grupo adotou **[Conventional Commits](https://www.conventionalcommits.org/)**, no formato `<tipo>: <descrição no imperativo>`.

| Tipo | Uso |
|---|---|
| `feat` | nova funcionalidade ou novo cenário de uma funcionalidade |
| `fix` | correção de comportamento |
| `test` | cenários BDD e step definitions |
| `refactor` | mudança interna sem alteração de comportamento |
| `docs` | documentação, incluindo esta wiki |
| `chore` | configuração de ambiente e ferramental |

Exemplos reais desta sprint:

```
test: adicionar cenários BDD de recarga de saldo
feat: add BDD for current meal menu
refactor: usar User com perfil no lugar de um model Funcionario
```

### Política de branching

Três níveis, do mais estável ao mais volátil:

```
main                    ← histórico estável do fork
└── sprint-01           ← branch de integração da sprint
    ├── feat/<escopo>   ← branch de feature, individual
    └── fix/<escopo>    ← branch de correção, individual
```

- `main` recebe apenas o resultado consolidado de uma sprint encerrada.
- `sprint-01` concentra todo o trabalho da Sprint 1 e é a base dos Pull Requests individuais.
- Cada integrante trabalha em sua própria branch, nomeada pelo escopo da entrega (ex.: `feat/recarga-acesso-e-exportacao`, `feat/restaurantes-catracas`).
- Ao final da sprint, o grupo gera uma **tag de release** e abre um Pull Request de `sprint-01` para a `main` do **repositório principal**, com o título no formato `Grupo XX - Sprint 1` e o nome e a matrícula dos integrantes no comentário.

### Política de revisão

- Todo Pull Request tem como destino a branch `sprint-01` do fork.
- **Nenhum integrante aprova o próprio PR**: a revisão é feita por outro aluno do grupo.
- O revisor confere se os cenários cobrem **ao menos um caminho feliz e um caminho triste**, se as regras de negócio assumidas estão explicitadas na descrição do PR e se as mensagens de commit seguem o padrão adotado.
- O PR só é integrado após a aprovação do revisor.

> **Observação de transparência.** As políticas acima foram as definidas pelo grupo, e a aderência a elas evoluiu ao longo da sprint. Parte dos commits iniciais foi enviada diretamente para a branch `sprint-01`, sem branch de feature nem Pull Request, e algumas mensagens desse período não seguem Conventional Commits. A segunda metade da sprint seguiu o fluxo completo: os PRs [#18](https://github.com/pedrofernandss/unb-ru/pull/18), [#19](https://github.com/pedrofernandss/unb-ru/pull/19) e [#20](https://github.com/pedrofernandss/unb-ru/pull/20) foram revisados por outro integrante antes de serem integrados. O #20 exemplifica a política funcionando como deveria: a revisão apontou um arquivo de feature sem cenários, um step duplicado que gerava ambiguidade no Cucumber e dois erros de código, e o merge só ocorreu depois das correções. A exceção foi o PR [#17](https://github.com/pedrofernandss/unb-ru/pull/17), integrado pelo próprio autor sem revisão. O grupo assume a revisão por terceiro como condição obrigatória de merge a partir da Sprint 2.

---

## 5. Pontuação das histórias e Velocity

Os pontos seguem a escala de **Fibonacci** (1, 2, 3, 5, 8) e medem **complexidade relativa** — quantidade de regras de negócio, número de validações, criticidade do caminho triste e dependência de outras histórias —, não tempo de trabalho.

| # | História | Responsável | Pontos | Entregue |
|---|---|---|---:|:---:|
| 1 | Cadastro de Usuário | [@pedrofernandss](https://github.com/pedrofernandss) | 3 | ✅ |
| 2 | Recarga de Saldo | [@Hendrickhmq](https://github.com/Hendrickhmq) | 5 | ✅ |
| 3 | Extrato e Histórico | [@pedrofernandss](https://github.com/pedrofernandss) | 5 | ✅ |
| 4 | Autenticação do Funcionário | [@pedrofernandss](https://github.com/pedrofernandss) | 3 | ✅ |
| 5 | Configuração de Ponto de Acesso | [@Hendrickhmq](https://github.com/Hendrickhmq) | 3 | ✅ |
| 6 | Validação de Entrada | [@DaviDias21](https://github.com/DaviDias21) | 5 | ✅ |
| 7 | Histórico Local da Catraca | [@DaviDias21](https://github.com/DaviDias21) | 2 | ✅ |
| 8 | Gestão de Restaurantes e Catracas | [@HimeakLucas](https://github.com/HimeakLucas) | 8 | ✅ |
| 9 | Relatório Global de Acessos | [@HimeakLucas](https://github.com/HimeakLucas) | 8 | ✅ |
| 10 | Cardápio da Refeição Atual | [@DaviDias21](https://github.com/DaviDias21) | 3 | ✅ |
| 11 | Exportação em PDF do Histórico | [@Hendrickhmq](https://github.com/Hendrickhmq) | 3 | ✅ |
| 12 | Exportação em PDF do Relatório | [@HimeakLucas](https://github.com/HimeakLucas) | 2 | ✅ |
| 13 | Inscrição Única no FastPass | [@pedrofernandss](https://github.com/pedrofernandss) | 5 | ✅ |
| 14 | Notificação de Sorteio | [@DaviDias21](https://github.com/DaviDias21) | 3 | ✅ |
| 15 | Validação Rigorosa FastPass | [@Hendrickhmq](https://github.com/Hendrickhmq) | 5 | ✅ |
| 16 | Gestão de Turnos e Time-Frames | [@HimeakLucas](https://github.com/HimeakLucas) | 8 | ✅ |
| | **Total planejado** | | **71** | |

### Velocity da Sprint 1

| Métrica | Valor |
|---|---|
| Pontos planejados | 71 |
| Pontos **entregues** (Velocity) | **71** |
| Pontos não entregues | 0 |
| Taxa de conclusão | 100% |

**Velocity = 71 pontos.** As 16 histórias planejadas foram especificadas e integradas à branch `sprint-01`, sem saldo de backlog para a próxima sprint. Essa é a referência de capacidade do grupo para o planejamento da Sprint 2.

Distribuição por integrante:

| Integrante | Planejado | Entregue |
|---|---:|---:|
| Lucas Adeodato de Oliveira | 26 | 26 |
| Pedro Fernandes de Oliveira | 16 | 16 |
| Hendrick Henrique Moreno Quevedo | 16 | 16 |
| Davi Dias da Silva Cruz | 13 | 13 |
| Arthur Fernandes Vargas | 0 | 0 |

Arthur Fernandes Vargas não assumiu histórias do backlog nesta sprint. Os pontos medem o esforço de especificação das histórias de usuário e não contabilizam atividades de condução do processo.

---

## 6. Cenários BDD especificados

A especificação exige que cada feature tenha **ao menos um caminho feliz e um caminho triste**. Todas as 15 features integradas à branch `sprint-01` atendem ao critério.

| Arquivo | História | Cenários | Feliz | Triste |
|---|---|---:|:---:|:---:|
| `features/cadastro.feature` | #1 | 2 | ✅ | ✅ |
| `features/recarga.feature` | #2 | 3 | ✅ | ✅ |
| `features/extrato.feature` | #3 | 2 | ✅ | ✅ |
| `features/login.feature` | #4 | 3 | ✅ | ✅ |
| `features/ponto_de_acesso.feature` | #5 | 2 | ✅ | ✅ |
| `features/validacao_saldo.feature` | #6 | 2 | ✅ | ✅ |
| `features/historico_catraca.feature` | #7 | 2 | ✅ | ✅ |
| `features/restaurantes_catracas.feature` | #8 | 11 | ✅ | ✅ |
| `features/relatorio_global.feature` | #9 e #12 | 9 | ✅ | ✅ |
| `features/cardapio_atual.feature` | #10 | 2 | ✅ | ✅ |
| `features/exportacao_pdf.feature` | #11 | 2 | ✅ | ✅ |
| `features/fastpass.feature` | #13 | 2 | ✅ | ✅ |
| `features/notificacao_fastpass.feature` | #14 | 2 | ✅ | ✅ |
| `features/validacao_fastpass.feature` | #15 | 3 | ✅ | ✅ |
| `features/turnos_timeframes.feature` | #16 | 5 | ✅ | ✅ |
| | **Total** | **52** | | |

Os testes são executados com **Cucumber** e **Capybara**, através de `bin/cucumber`.

---

## 7. Uso de Inteligência Artificial

Conforme exigido pela disciplina, o grupo declara abaixo o uso de IA generativa nesta sprint.

### Hendrick Henrique Moreno Quevedo ([@Hendrickhmq](https://github.com/Hendrickhmq))

| | |
|---|---|
| **Ferramenta** | Claude (Anthropic), via Claude Code |
| **Onde foi usada** | Preparação do ambiente de desenvolvimento, especificação dos cenários BDD das histórias #2, #5, #11 e #15 com seus step definitions (PR [#18](https://github.com/pedrofernandss/unb-ru/pull/18)) e redação desta página da wiki |

**Estratégia.** O protótipo do Figma foi lido tela a tela antes da escrita de cada `.feature`, para que os rótulos de campos, botões e mensagens dos cenários fossem os da interface projetada em vez de inventados. Os step definitions já existentes no projeto foram reaproveitados, evitando steps ambíguos, e cada feature recebeu ao menos um caminho feliz e um triste conforme a taxonomia da especificação da disciplina. A cada alteração, `cucumber --dry-run` e RuboCop foram executados para verificar o resultado.

O material gerado foi revisado e redirecionado em vários pontos: a primeira versão trazia 22 cenários e foi reduzida a 10, para ficar coerente com o volume entregue pelos demais integrantes; a divergência entre os models assumidos nos PRs [#17](https://github.com/pedrofernandss/unb-ru/pull/17) e [#18](https://github.com/pedrofernandss/unb-ru/pull/18) foi identificada e corrigida pelo commit `refactor: usar User com perfil no lugar de um model Funcionario`; e as regras de negócio que precisaram ser assumidas — faixa de 1 a 50 refeições, tarifa de R$ 4,50 e janela do FastPass sem tolerância — foram registradas na descrição do Pull Request para revisão do grupo, em vez de embutidas silenciosamente nos cenários.

> ⚠️ **Cada integrante precisa preencher a própria declaração.** A especificação determina que uso não justificado, ou que o aluno não saiba explicar, reduz a nota. Descreva a ferramenta, a parte exata do projeto e a estratégia (prompts, agentes, skills). Quem não usou IA deve declarar isso explicitamente.

### Pedro Fernandes de Oliveira ([@pedrofernandss](https://github.com/pedrofernandss))

| | |
|---|---|
| **Ferramenta** | `⟨A PREENCHER⟩` |
| **Onde foi usada** | `⟨A PREENCHER⟩` |
| **Estratégia** | `⟨A PREENCHER⟩` |

### Davi Dias da Silva Cruz ([@DaviDias21](https://github.com/DaviDias21))

| | |
|---|---|
| **Ferramenta** | `⟨A PREENCHER⟩` |
| **Onde foi usada** | `⟨A PREENCHER⟩` |
| **Estratégia** | `⟨A PREENCHER⟩` |

### Lucas Adeodato de Oliveira ([@HimeakLucas](https://github.com/HimeakLucas))

| | |
|---|---|
| **Ferramenta** | `⟨A PREENCHER⟩` |
| **Onde foi usada** | `⟨A PREENCHER⟩` |
| **Estratégia** | `⟨A PREENCHER⟩` |

### Arthur Fernandes Vargas

| | |
|---|---|
| **Ferramenta** | `⟨A PREENCHER⟩` |
| **Onde foi usada** | `⟨A PREENCHER⟩` |
| **Estratégia** | `⟨A PREENCHER⟩` |

---

## 8. Pontos em aberto para a próxima etapa

Registrados aqui para dar continuidade à segunda etapa da entrega (23/10/2026).

**Divergências de modelo já integradas à `sprint-01`.** As histórias foram especificadas em paralelo, e cada conjunto de cenários assumiu um modelo de dados próprio. Com os merges dos PRs #17, #18 e #19, essas suposições incompatíveis passaram a conviver na mesma branch. Unificá-las é o primeiro trabalho do modelo entidade-relacionamento:

| Conceito | Desenhos hoje presentes na `sprint-01` |
|---|---|
| Catraca | `Catraca(nome, piso)` com piso numérico validado contra o restaurante (#8); `Catraca(identificacao, online)` (#5, #15); `Catraca(piso)` com piso em texto, como `"Piso 2"` (#7) |
| Registro de acesso | `Acesso` (#9), `AcessoCatraca` (#7), `Lancamento` (#11), `Transaction` (#3) — quatro nomes para a mesma entidade |
| Perfil de funcionário | `User` com campo `perfil` |

Como os step definitions coexistem na mesma suíte, essas divergências deixaram de ser uma questão de nomenclatura e passaram a ser um impedimento concreto para a implementação da Sprint 2.

**Regra conflitante de tolerância no FastPass.** A história #16 prevê um campo "Tolerância de Atraso" para os time-frames, enquanto os cenários da #15 adotam janela exata, sem tolerância, seguindo o protótipo do Figma ("Critério de Horário Exato"). O grupo precisa decidir qual das duas regras vale antes da implementação.

**Mensagem de erro inconsistente no login.** Os cenários da #4 usam "Matrícula ou senha inválidos." para senha incorreta e "E-mail ou senha inválidos." para matrícula inexistente. Como o sistema autentica por matrícula e a mensagem não deve revelar qual campo falhou, as duas precisam ser unificadas.

**Integração contínua.** O workflow do GitHub Actions está falhando por motivos estruturais: o projeto ainda não possui `db/schema.rb`, por não ter migrations, e há ofensas de RuboCop em arquivos herdados do commit inicial. Pendente de correção.
