# Descrições de PR — rascunhos locais

## #11 — feat: exportação do extrato filtrado em PDF

O botão de exportação estava desabilitado. Agora o estudante exporta todas as suas transações que atendem às datas, tipo, restaurante e método selecionados, incluindo registros além da página atual. O documento tem cabeçalho, acentos e paginação; uma consulta vazia retorna à tela com o aviso exigido e conserva os filtros.

Reutiliza `Extrato`, `Transacao` e o controller/layout existentes. Adiciona Prawn, leitura de PDF em teste e a estrutura RSpec, preservando Minitest. Não exporta os indicadores do período como totais das linhas filtradas.

Validação: 2 BDD aprovados; specs exercitam arquivo PDF real, 65 registros, múltiplas páginas, filtros, usuário diferente e estado vazio. Revisão visual do PDF realizada. Comparar `hendrick/issue-11-pdf` com `sprint-02`.

Teste: `bundle exec cucumber features/exportacao_pdf.feature` e `bundle exec rspec spec/requests/exportacao_pdf_spec.rb`.

## #2 — feat: recarga de carteira com confirmação idempotente

Adiciona `/recarga`, pacotes 2/5/10/20 e quantidade personalizada inteira entre 1 e 50. O servidor calcula o valor a R$ 4,50 por refeição. PIX/cartão passam por revisão de pagamento e adaptador simulável. Uma aprovação atualiza `User.saldo` e cria crédito em `Transacao` atomicamente; recusa não gera crédito. Repetição da operação/confirmacão não cobra nem credita novamente.

O simulador funciona em desenvolvimento/teste. Produção permanece pendente sem um provedor configurado; não são armazenados dados bancários reais. O gateway futuro deve respeitar a chave de idempotência.

Validação: 3 BDD aprovados; specs HTTP cobrem PIX/cartão, limites, quantidade fracionária/inválida, recusa, isolamento, repetição, rollback e integração com PDF. Fluxo de aprovação conferido no navegador. Depende da base local de #11; comparar com `hendrick/issue-11-pdf`.

Teste: `bundle exec cucumber features/recarga.feature` e `bundle exec rspec spec/requests/recargas_spec.rb`.

## #5 — feat: contexto operacional de restaurante e catraca por sessão

Substitui a página de configuração em construção por uma área de funcionário. Lista restaurantes reais e catracas por piso; recusa seleção ausente, combinação incompatível e equipamento offline. O terminal e o histórico consomem exclusivamente a catraca escolhida nesta sessão. Login/logout e perda de disponibilidade invalidam o contexto, sem sobrescrever o responsável cadastral em `funcionario_id`.

Adiciona `online` com padrão false. Alinhar esse atributo com Lucas (#8). As rotas/layouts operacionais e o contexto são pontos de integração com o terminal/histórico de Davi; o histórico completo de #7 continua sendo responsabilidade dele.

Validação: 2 BDD aprovados e specs de perfil, seleção, troca, logout, duas sessões, disponibilidade e isolamento do histórico. Erro offline e acesso ao terminal conferidos no navegador. Comparar com `hendrick/issue-2-recarga`.

Teste: `bundle exec cucumber features/ponto_de_acesso.feature` e `bundle exec rspec spec/requests/pontos_de_acesso_spec.rb`.

## #15 — feat: validação FastPass por data e janela exata

Aplica a contemplação de `InscricaoFastpass` à data/turno da operação e à janela `TimeFrame`. A janela 12:15–12:30 inclui 12:30:00 e bloqueia 12:30:01, sem tolerância adicional, conforme decisão explícita do usuário. Saldo insuficiente, ausência de contemplação, outra data/unidade ou janela apagada bloqueiam sem débito.

O terminal usa o relógio do servidor e chama um único fluxo comum de débito, transação, histórico e comando. O evento tem chave única para impedir processamento duplicado. A entrega pendente de comando pode ser repetida sem novo débito; o adaptador físico futuro deve deduplicar essa chave. Há simulador local e bloqueio padrão sem dispositivo em produção.

Depende dos PRs #27/#28 do Arthur, integrados somente na branch local. Coordenar com Davi o reaproveitamento do serviço/contexto; não duplicar o mecanismo de débito. Comparar a implementação própria a partir do merge local `918191b`, revisando também a correção de configuração dos adaptadores.

Validação: 3 BDD aprovados, 19 specs HTTP de FastPass e 2 de adaptadores, além da regressão integrada (47 RSpec, 35 Minitest e 28 BDD afetados aprovados). Bloqueio/liberação foram conferidos no navegador. A suíte BDD global ainda tem funcionalidades do grupo falhando; ver `entrega.md`.

Teste: `bundle exec cucumber features/validacao_fastpass.feature` e `bundle exec rspec spec/requests/fastpass_spec.rb spec/services/adaptadores_spec.rb`.
