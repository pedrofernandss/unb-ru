# Sprint 2 — Recarga, Ponto de Acesso, PDF e FastPass

Responsável: @Hendrickhmq. Rascunho para revisão e publicação manual autorizada.

## Recarga de Saldo — #2

O estudante seleciona pacote ou quantidade personalizada de 1 a 50 refeições, escolhe PIX/cartão e confere o resumo antes de concluir. O servidor calcula o valor a R$ 4,50 por refeição. A confirmação aprovada gera uma única atualização de saldo e um crédito no extrato; a recusa conserva o saldo. A demonstração usa pagamento simulado, sem dados bancários reais.

## Configuração de Ponto de Acesso — #5

O funcionário seleciona restaurante e catraca agrupada por piso. A catraca precisa pertencer à unidade e estar online. O vínculo pertence à sessão autenticada, termina no logout e é revalidado pelo terminal/histórico. O responsável cadastral da catraca permanece independente desse vínculo. A disponibilidade deve ser mantida pela integração de administração/dispositivo de #8.

## Exportação do Histórico em PDF — #11

O estudante exporta as próprias transações usando os filtros do extrato, incluindo todas as páginas. O PDF tem nome `extrato-refeicoes.pdf` e cabeçalho “Extrato e Histórico de Refeições”. Consulta vazia exibe “Não há lançamentos no período selecionado” e não gera arquivo. O PDF apresenta os lançamentos filtrados, sem confundir seus totais com os indicadores gerais do período.

## Validação Rigorosa FastPass — #15

A leitura consulta contemplação, data, turno e janela, respeitando o contexto da catraca e o fuso Brasília. Os limites são inclusivos e não há tolerância extra: para janela 12:15–12:30, 12:30:00 permite e 12:30:01 bloqueia. Dentro da janela, saldo insuficiente também bloqueia. A aprovação passa por um único fluxo comum de débito, histórico e comando; a mesma leitura não pode ser processada duas vezes.

## Qualidade e integração

Foram preservados `User.saldo`, `Transacao`, autenticação, extrato, componentes HAML/CSS e Minitest do grupo. RSpec foi adicionado em paralelo. `InscricaoFastpass`, `TimeFrame` e `TipoRefeicao` vêm dos PRs #27/#28 de Arthur. O terminal/histórico e a disponibilidade têm contratos documentados para integração com Davi e Lucas.

Resultados locais integrados: 10 BDD das quatro issues aprovados; 28 BDD afetados aprovados; 47 specs RSpec aprovados; 35 testes Minitest aprovados. A suíte BDD completa ainda apresenta 28 falhas e 4 ambiguidades em funcionalidades fora destas quatro issues. Ver relatório de entrega e logs antes de aceitar a sprint inteira.

Uso de IA: o Codex auxiliou na inspeção, implementação e execução dos testes. O material precisa de revisão humana do responsável e do grupo antes de publicação, integração e aceite.
