# Steps da issue #5 - Configuração de Ponto de Acesso

# O funcionário é um User com perfil próprio, e não um model separado: a tela de
# cadastro usa um único campo "Matrícula SIGAA ou SIAPE" para estudante e servidor.
Given('que eu estou logado como funcionário do restaurante') do
  @funcionario = User.create!(
    nome: 'Funcionário Teste',
    matricula: '4598210',
    password: 'senha123',
    perfil: 'funcionario'
  )
  visit '/login'
  fill_in 'Matrícula', with: @funcionario.matricula
  fill_in 'Senha', with: 'senha123'
  click_button 'Entrar'
end

Given('o sistema possui as seguintes catracas cadastradas:') do |table|
  table.hashes.each do |linha|
    restaurante = restaurante_de_teste(linha['restaurante'])
    Catraca.create!(
      restaurante: restaurante,
      numero: linha['catraca'].split.last.to_i,
      piso: 1,
      online: linha['situacao'] == 'Online'
    )
  end
end

Given('que eu acesso a página de configuração de ponto de acesso') do
  visit '/configuracao-de-ponto'
end

When('eu seleciono a unidade operacional {string}') do |nome|
  within('.unidades-operacionais') do
    choose nome
  end
end

When('eu seleciono a catraca física {string}') do |identificacao|
  within('.catracas-fisicas') do
    choose identificacao
  end
end

Then('a minha sessão deve estar vinculada à catraca {string}') do |identificacao|
  expect(page).to have_css('.contexto-operacao', text: identificacao)
  expect(@funcionario.reload.catraca).to be_nil
end

Then('a minha sessão não deve estar vinculada a nenhuma catraca') do
  visit '/terminal-de-validacao'
  expect(page).to have_current_path('/configuracao-de-ponto')
  expect(@funcionario.reload.catraca).to be_nil
end
