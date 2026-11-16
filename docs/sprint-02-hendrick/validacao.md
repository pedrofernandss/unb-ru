# Execução e reprodução dos testes

## Ambiente

Ruby 3.4.10, Rails 8.1.4, SQLite, Bundler 2.6.9. `Gemfile.lock` mantém as plataformas Linux e adiciona Windows. Usar um banco de teste descartável, separado de desenvolvimento/produção.

Em um ambiente Ruby configurado normalmente:

```sh
bundle install
RAILS_ENV=test bundle exec rails db:create db:migrate
bundle exec rspec
bundle exec cucumber features/exportacao_pdf.feature features/recarga.feature features/ponto_de_acesso.feature features/validacao_fastpass.feature
bundle exec cucumber features/exportacao_pdf.feature features/recarga.feature features/ponto_de_acesso.feature features/validacao_fastpass.feature features/extrato.feature features/login.feature features/cadastro.feature features/fastpass.feature features/turnos_timeframes.feature
RAILS_ENV=test bundle exec rails test
RAILS_ENV=test bundle exec rails zeitwerk:check
```

`bundle exec cucumber` executa também as funcionalidades ainda pendentes de outros responsáveis e atualmente não fica verde. Não substituir a regressão afetada pelo resultado global sem examinar as falhas.

## Windows deste trabalho

Os atalhos globais misturavam Ruby 3.3 e 3.4. A instalação isolada de gems fica em `work/gems`, fora do Git. No clone principal, `.bundle/config` aponta para essa pasta. Os comandos efetivamente usados foram:

```powershell
$rubyExec = 'C:\Ruby34-x64\bin\ruby.exe'
$env:RAILS_ENV = 'test'
$env:PARALLEL_WORKERS = '1'
& $rubyExec -rbundler/setup bin/rails db:create db:migrate
& $rubyExec -rbundler/setup -e 'load Gem.bin_path("rspec-core", "rspec")' -- spec
& $rubyExec -rbundler/setup -e 'load Gem.bin_path("cucumber", "cucumber")' -- features/exportacao_pdf.feature features/recarga.feature features/ponto_de_acesso.feature features/validacao_fastpass.feature --format progress --publish-quiet
& $rubyExec -rbundler/setup bin/rails test
& $rubyExec -rbundler/setup bin/rails zeitwerk:check
```

O `haml-rails` 3.1.0 contém links simbólicos de templates. O Windows não permitiu criá-los; no ambiente isolado, esses templates foram materializados como cópias do conteúdo original da gem. Essa preparação não altera o código do projeto. O script local de preparação foi mantido em `work/install_haml_windows.py`.

O primeiro `db:prepare` inseriu seeds no banco de teste; isso interferiu nas fixtures Minitest. O arquivo de teste desse clone foi recriado com as conexões fechadas, e as migrations foram executadas sem seeds. Após a limpeza, Minitest passou. Não é necessário nem apropriado desativar chaves estrangeiras para esconder essas falhas.

## Revisão manual

1. Em desenvolvimento, executar `rails db:prepare` e iniciar o servidor em localhost.
2. Login de aluno: visitar `/recarga`, escolher 5 refeições e PIX, Confirmar, conferir R$ 22,50 e Concluir pagamento. O simulador atualiza saldo e extrato. Repetir a mesma confirmação não gera novo crédito.
3. Em `/extrato`, aplicar datas/filtros e Exportar PDF. Verificar o conteúdo. Usar um período vazio e conferir o aviso sem download.
4. Login de funcionário: a autenticação real redireciona para `/configuracao-de-ponto`. O atalho de desenvolvimento herdado do grupo sempre vai para `/home`; nesse caso abrir a rota operacional explicitamente.
5. A disponibilidade padrão é offline. Para demonstração local, marcar no banco de desenvolvimento uma catraca real como online. Testar a catraca offline, uma combinação de outra unidade e a vinculação correta.
6. No terminal, verificar o contexto escolhido, tentar aluno sem contemplação e verificar bloqueio sem débito. Preparar inscrição contemplada na data/janela vigente somente como dado de demonstração; o terminal continua usando o relógio real do servidor.

Os valores/usuários de exemplo são dos seeds. A criação de contemplação no banco de demonstração não substitui a implementação da notificação/sorteio #14.
