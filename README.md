# UnB-RU

Sistema de gerenciamento do Restaurante Universitário da Universidade de
Brasília, desenvolvido em Ruby on Rails para a disciplina de Engenharia de
Software. O sistema cobre o dia a dia do RU em três áreas:

- **Portal do Estudante**: cadastro e login, consulta do cardápio do dia,
  recarga de saldo, extrato de recargas e refeições com exportação em PDF e
  inscrição no sorteio do FastPass (fila prioritária com janela de horário).
- **Terminal Operacional**: o funcionário assume uma catraca, valida o QR Code
  do estudante (saldo ou FastPass) e acompanha o histórico de acessos da catraca.
- **Administração**: gestão de restaurantes e catracas, turnos e time-frames das
  refeições e relatório global de acessos com exportação em PDF.

Os requisitos estão descritos como cenários BDD em [`features/`](features/) e o
modelo de dados em [`docs/entity-relationship-model.md`](docs/entity-relationship-model.md).

## Tecnologias

- Ruby 3.4.10 (ver [`.ruby-version`](.ruby-version)) e Rails 8.1
- SQLite como banco de dados
- HAML para as views, Propshaft para os assets e Hotwire (Turbo e Stimulus)
- Minitest, Cucumber e Capybara para os testes
- RuboCop (estilo omakase) e Brakeman para análise estática

## Como executar

### Pré-requisitos

- Ruby 3.4.10. Recomendamos um gerenciador de versões como
  [mise](https://mise.jdx.dev/) ou [rbenv](https://github.com/rbenv/rbenv),
  que leem o `.ruby-version` automaticamente.
- SQLite 3 e as bibliotecas de compilação do sistema (`build-essential` e
  `libsqlite3-dev` no Debian/Ubuntu).
- Google Chrome, apenas para os testes de sistema e cenários com JavaScript.

### Instalação

```bash
git clone https://github.com/pedrofernandss/unb-ru.git
cd unb-ru
bin/setup --skip-server   # instala as gems e cria o banco (db:prepare)
bin/rails db:seed         # dados de exemplo (ver abaixo)
```

### Rodando a aplicação

```bash
bin/dev
```

A aplicação sobe em <http://localhost:3000>.

### Dados de exemplo

O comando `bin/rails db:seed` é idempotente e cria a UnB com quatro campi e
restaurantes (Darcy Ribeiro, Gama, Ceilândia e Planaltina), as catracas de cada
um, os tipos de refeição com seus horários, o cardápio da semana atual a partir
de [`cardapio.json`](cardapio.json) e três usuários, todos com a senha `senha123`:

| Perfil | Matrícula |
|---|---|
| Administrador | `1000001` |
| Funcionário | `1984201` |
| Aluno | `2023123456` |

Para recomeçar do zero: `bin/rails db:reset` (recria o banco e roda os seeds).

## Testes e qualidade

```bash
bin/rails test                                 # testes unitários e de integração (Minitest)
bundle exec cucumber                           # todos os cenários BDD
bundle exec cucumber features/cadastro.feature # uma feature específica
bin/rubocop                                    # estilo de código
bin/brakeman --no-pager                        # vulnerabilidades comuns do Rails
```

Os cenários em `features/` são executados por padrão com o driver `rack_test`,
que não executa JavaScript. Por isso toda tela deve funcionar com formulários e
links comuns, e o Hotwire entra como melhoria progressiva.

## Estrutura do projeto

| Caminho | Conteúdo |
|---|---|
| `app/models/` | Entidades do MER: `User` (aluno, funcionário e administrador), `Universidade`, `Campus`, `Restaurante`, `Catraca`, `Cartao`, `TipoRefeicao`, `Refeicao`, `Transacao`, `InscricaoFastpass` e `HistoricoCatraca` |
| `app/views/` | Views em HAML, com layouts por área e partials compartilhados em `shared/` |
| `app/assets/stylesheets/` | CSS próprio com design tokens (variáveis em `:root`) |
| `app/javascript/controllers/` | Controllers Stimulus |
| `db/migrate/`, `db/seeds.rb` | Migrations e dados iniciais |
| `features/` | Cenários BDD (Gherkin em português) e step definitions |
| `docs/` | Modelo entidade-relacionamento e o spike de implementação das views |
| `config/initializers/inflections.rb` | Plurais em português usados pelos models (campi, cartões, refeições...) |

## Fluxo de trabalho

A branch `main` recebe apenas o resultado de cada sprint. O trabalho acontece em
branches de sprint (`sprint-01`, `sprint-02`, ...) e cada funcionalidade é feita
em uma branch criada a partir da sprint atual, integrada por pull request. A
branch `sprint-02` já contém o banco de dados completo, então as novas
funcionalidades devem partir dela.

## Deploy

O projeto já vem com `Dockerfile` e configuração do
[Kamal](https://kamal-deploy.org) em `config/deploy.yml`, herdados do template
do Rails 8. Não há ambiente de produção configurado no momento.
