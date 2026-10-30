Given('que existe um estudante cadastrado com a matrícula {string} e senha {string}') do |matricula, senha|
  User.create!(
    nome: 'Estudante Teste',
    matricula: matricula,
    password: senha
  )
end

Given('que eu estou na página de login') do
  visit '/login'
end

When('eu preencho o campo {string} com {string}') do |nome_do_campo, valor|
  fill_in nome_do_campo, with: valor
end

When('eu deixo o campo {string} vazio') do |nome_do_campo|
  fill_in nome_do_campo, with: ""
end

When('eu clico no botão {string}') do |texto_botao|
  click_button texto_botao
end

Then('eu devo ser redirecionado para a página inicial') do
  expect(page).to have_current_path('/home')
end

Then('eu devo permanecer na página de login') do
  expect(page).to have_current_path('/login')
end

Then('eu devo ver a mensagem {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end
