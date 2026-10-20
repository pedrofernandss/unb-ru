Given('que o estudante está logado no aplicativo') do
  @estudante = User.create!(
    nome: 'Estudante Com Fome',
    matricula: '26100003',
    password: 'senha123'
  )
  login_as(@estudante, scope: :user)
end

Given ('ele está na página inicial') do
  visit '/home'
end

Then ('ele deve ver uma seção intitulada {string}') do |titulo_cardapio|
  expect(page).to have_content(titulo_cardapio)
end

Then ('ele deve ver um botão intitulado {string}') do |botao_cardapio|
  expect(page).to have_content(botao_cardapio)
end

When ('nenhuma refeição está sendo servida') do
  Meal.destroy_all # Limpa a tabela das refeições
end

When('uma refeição está sendo servida') do
  @refeicao = Meal.create!(
    tipo: 'Almoço',
    opcao_padrao: 'Peixe ao molho branco gratinado.',
    opcao_ovolacto: 'Ovos assados ao sugo',
    opcao_veg_estrito: 'Refogado de grão de bico'
  )
end

When('estudante aperta o botão {string}') do |botao_cardapio|
  click_button botao_cardapio
end

Then('ele deve ver um erro dizendo: {string}') do |mensagem_erro|
  expect(page).to have_content(mensagem_erro)
end

Then('ele deve ver qual refeição está sendo servida \(café da manhã, almoço, jantar\)') do
  expect(page).to have_content (@refeicao.tipo)
end

Then('todas as opções da refeição \(padrão, ovolactovegetariano e vegetariano estrito\)') do
  expect(page).to have_content (@refeicao.opcao_padrao)
  expect(page).to have_content (@refeicao.opcao_ovolacto)
  expect(page).to have_content (@refeicao.opcao_veg_estrito)
end
