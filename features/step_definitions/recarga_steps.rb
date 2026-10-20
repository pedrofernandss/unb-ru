# Steps da issue #2 - Recarga de Saldo
# O helper valor_em_reais vive em features/support/helpers.rb

Given('o meu saldo atual é de {string}') do |valor|
  @estudante.update!(saldo: valor_em_reais(valor))
end

Given('que eu acesso a página de recarga de saldo') do
  visit '/recarga'
end

When('eu escolho o pacote {string}') do |nome_pacote|
  within('.pacotes-de-refeicoes') do
    choose nome_pacote
  end
end

When('eu informo a quantidade personalizada de {string} refeições') do |quantidade|
  fill_in 'Outra quantidade', with: quantidade
end

When('eu seleciono o método de pagamento {string}') do |metodo|
  within('.metodos-de-pagamento') do
    click_on metodo
  end
end

# O provedor externo é simulado: o cenário decide se a cobrança volta aprovada ou recusada.
When('o provedor de pagamento aprova a transação') do
  ProvedorDePagamentoFake.aprovar!(@estudante.recargas.last)
end

When('o provedor de pagamento recusa a transação') do
  ProvedorDePagamentoFake.recusar!(@estudante.recargas.last)
end

Then('o meu saldo deve ser {string}') do |valor|
  expect(@estudante.reload.saldo).to eq(valor_em_reais(valor))
end
