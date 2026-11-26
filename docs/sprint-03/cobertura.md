# Cobertura dos testes (Sprint 3)

**Requisito:** cobertura dos testes RSpec acima de 90% em cada controller e model implementado pelo grupo, medida com o SimpleCov.

**Resultado:** todos os models, controllers, services e helpers ficaram acima de 90%. O menor é o `admin/restaurantes_controller.rb`, com 92,3%. A cobertura total de `app/` passou de **91,87%** para **99,33%**.

## Como medir

```
bundle exec rspec
```

Ao final, o SimpleCov grava o relatório em `coverage/index.html` (linha por linha, com abas Models, Controllers, Services e Helpers) e em `coverage/coverage.json`. A pasta `coverage/` não vai para o repositório.

A configuração fica no topo de `spec/rails_helper.rb`, antes de o app ser carregado.
- **Perfil `rails`:** já ignora `spec/`, `test/`, `features/`, `config/` e `db/`.
- **Grupo Services:** foi o único adicionado.
- **`app/jobs` e `app/mailers`:** ficam fora do relatório, porque só têm as classes base que o Rails gera.
- **Minitest e Cucumber:** não entram na conta; a medição é só do RSpec.

No CI (quando a variável `CI` existe, como no GitHub Actions), a suíte falha se algum arquivo ficar abaixo de 90%:

```
CI=1 bundle exec rspec
# Line coverage by file (87.50%) is below the expected minimum coverage (90.00%) in app/models/transacao.rb.
# SimpleCov failed with exit 2 due to a coverage related error
```

(Saída de um teste da trava, rodando a suíte sem o `transacao_spec.rb`.)

## Antes e depois

Os valores são de cobertura de linhas.
- **Antes:** a `sprint-03` em `f7dfed0`, com 196 exemplos. O total de antes ainda contava `app/jobs` e `app/mailers`, que tinham 4 linhas sem teste.
- **Depois:** esta branch, com 242 exemplos.

### Models

| Arquivo | Antes | Depois |
|---|---:|---:|
| `cartao.rb` | **0,0% (0/5)** | 100,0% (5/5) |
| `transacao.rb` | **87,5% (21/24)** | 100,0% (24/24) |
| `tipo_refeicao.rb` | 98,7% (75/76) | 100,0% (76/76) |
| `application_record.rb` | 100,0% (2/2) | 100,0% (2/2) |
| `campus.rb` | 100,0% (4/4) | 100,0% (4/4) |
| `catraca.rb` | 100,0% (27/27) | 100,0% (27/27) |
| `current.rb` | 100,0% (2/2) | 100,0% (2/2) |
| `extrato.rb` | 100,0% (44/44) | 100,0% (44/44) |
| `historico_catraca.rb` | 100,0% (11/11) | 100,0% (11/11) |
| `inscricao_fastpass.rb` | 100,0% (28/28) | 100,0% (28/28) |
| `processamento_acesso.rb` | 100,0% (23/23) | 100,0% (23/23) |
| `recarga.rb` | 100,0% (28/28) | 100,0% (28/28) |
| `refeicao.rb` | 100,0% (29/29) | 100,0% (29/29) |
| `relatorio_global.rb` | 100,0% (60/60) | 100,0% (60/60) |
| `restaurante.rb` | 100,0% (22/22) | 100,0% (22/22) |
| `tarifa_refeicao.rb` | 100,0% (6/6) | 100,0% (6/6) |
| `time_frame.rb` | 100,0% (4/4) | 100,0% (4/4) |
| `universidade.rb` | 100,0% (3/3) | 100,0% (3/3) |
| `user.rb` | 100,0% (18/18) | 100,0% (18/18) |

### Controllers

| Arquivo | Antes | Depois |
|---|---:|---:|
| `admin/turnos_controller.rb` | **0,0% (0/26)** | 100,0% (26/26) |
| `paginas_controller.rb` | **0,0% (0/4)** | removido |
| `users_controller.rb` | **0,0% (0/14)** | 100,0% (14/14) |
| `sessions_controller.rb` | **77,3% (17/22)** | 100,0% (22/22) |
| `estudante/inscricoes_fastpass_controller.rb` | 92,0% (23/25) | 100,0% (25/25) |
| `admin/restaurantes_controller.rb` | 92,3% (24/26) | 92,3% (24/26) |
| `estudante/fastpass_controller.rb` | 94,7% (18/19) | 100,0% (19/19) |
| `estudante/recargas_controller.rb` | 95,1% (39/41) | 95,1% (39/41) |
| `operador/validacoes_controller.rb` | 96,6% (28/29) | 96,6% (28/29) |
| `admin/catracas_controller.rb` | 96,8% (30/31) | 96,8% (30/31) |
| `admin/base_controller.rb` | 100,0% (12/12) | 100,0% (12/12) |
| `admin/relatorios_controller.rb` | 100,0% (18/18) | 100,0% (18/18) |
| `application_controller.rb` | 100,0% (3/3) | 100,0% (3/3) |
| `concerns/authentication.rb` | 100,0% (33/33) | 100,0% (33/33) |
| `estudante/base_controller.rb` | 100,0% (7/7) | 100,0% (7/7) |
| `estudante/extratos_controller.rb` | 100,0% (14/14) | 100,0% (14/14) |
| `estudante/home_controller.rb` | 100,0% (14/14) | 100,0% (14/14) |
| `operador/base_controller.rb` | 100,0% (14/14) | 100,0% (14/14) |
| `operador/historicos_controller.rb` | 100,0% (5/5) | 100,0% (5/5) |
| `operador/pontos_de_acesso_controller.rb` | 100,0% (21/21) | 100,0% (21/21) |

### Services

| Arquivo | Antes | Depois |
|---|---:|---:|
| `validacao_de_acesso.rb` | 98,5% (67/68) | 98,5% (67/68) |
| `catracas.rb` | 100,0% (11/11) | 100,0% (11/11) |
| `documento_pdf.rb` | 100,0% (17/17) | 100,0% (17/17) |
| `extrato_pdf.rb` | 100,0% (35/35) | 100,0% (35/35) |
| `pagamentos.rb` | 100,0% (7/7) | 100,0% (7/7) |
| `regra_fastpass.rb` | 100,0% (28/28) | 100,0% (28/28) |
| `relatorio_global_pdf.rb` | 100,0% (45/45) | 100,0% (45/45) |

### Helpers

| Arquivo | Antes | Depois |
|---|---:|---:|
| `turnos_helper.rb` | **38,5% (5/13)** | 100,0% (13/13) |
| `extratos_helper.rb` | **68,8% (11/16)** | 100,0% (16/16) |
| `fastpass_helper.rb` | **83,3% (5/6)** | 100,0% (6/6) |
| `admin/relatorios_helper.rb` | 100,0% (8/8) | 100,0% (8/8) |
| `application_helper.rb` | 100,0% (6/6) | 100,0% (6/6) |

Em negrito estão os arquivos que começaram abaixo de 90%.

## O que foi feito

Cada spec novo tem caminho feliz e caminho triste. Nenhum `.feature` foi alterado e nenhum código de `app/` foi mudado para subir a cobertura.

| Arquivo | Spec | O que cobre |
|---|---|---|
| `admin/turnos_controller.rb` e `turnos_helper.rb` | `spec/requests/admin_turnos_spec.rb` (novo) | Lista, edição e atualização de horários (sobreposição, fim antes do início, 404), geração de time-frames (granularidade inválida ou que não divide o turno), avisos de descarte e de reconfiguração, bloqueio para aluno, funcionário e visitante. Antes só era testado pelo Cucumber. |
| `extratos_helper.rb` | `spec/helpers/extratos_helper_spec.rb` (novo) | Valor com sinal, "Hoje", "Ontem" e dia da semana, e as etiquetas de almoço, jantar, café, recarga e neutra. |
| `fastpass_helper.rb` | `spec/helpers/fastpass_helper_spec.rb` (novo) | Mensagem de cada status do sorteio e o erro para status sem mensagem. |
| `estudante/inscricoes_fastpass_controller.rb` | `spec/requests/inscricoes_fastpass_spec.rb` | Inscrição duplicada barrada só pelo índice único do banco (dois envios simultâneos). |
| `estudante/fastpass_controller.rb` | `spec/requests/resultado_fastpass_spec.rb` | Aviso no log quando o aluno tem duas inscrições no mesmo turno, e ausência do aviso no caso normal. |
| `tipo_refeicao.rb` | `spec/models/tipo_refeicao_spec.rb` | Horário formatado de um turno ainda sem horário. |
| `sessions_controller.rb` | `spec/requests/autenticacao_spec.rb` | Formulário, login por perfil, retorno à página pedida, senha ou matrícula inválida, logout, quem já está logado e o atalho que só aparece em desenvolvimento. |
| `users_controller.rb` | `spec/requests/cadastro_spec.rb` (novo) | Formulário, cadastro, senhas diferentes e matrícula repetida. |
| `transacao.rb` | `spec/models/transacao_spec.rb` (novo) | Local e detalhe no extrato (catraca, restaurante, recarga) e validações. |
| `cartao.rb` | `spec/models/cartao_spec.rb` (novo) | Campos obrigatórios, número único por aluno e saldo negativo. Nenhuma tela usa o model ainda, mas ele fica: o cartão é uma entidade do modelo ER do projeto (seção 6 de `docs/entity-relationship-model.md`). |
| `paginas_controller.rb` | — | Removido: era a página provisória "em construção" da Sprint 1. Desde o #5 e o #8 não tinha rota, e nenhum link, redirect ou teste chegava nele. |

Os arquivos que já estavam acima de 90% e não chegaram a 100% ficaram como estavam:
- `admin/restaurantes_controller.rb`
- `estudante/recargas_controller.rb`
- `operador/validacoes_controller.rb`
- `admin/catracas_controller.rb`
- `validacao_de_acesso.rb`

## Suítes

| Suíte | Antes | Depois |
|---|---:|---:|
| RSpec | 196 exemplos, 0 falhas | 242 exemplos, 0 falhas |
| Minitest | 10 testes, 0 falhas | 10 testes, 0 falhas |
| Cucumber | 66 cenários, 66 passando | 66 cenários, 66 passando |
| RuboCop | — | 156 arquivos, nenhuma ofensa |
