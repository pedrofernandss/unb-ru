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
    restaurante = Restaurante.find_or_create_by!(nome: linha['restaurante'])
    Catraca.create!(
      restaurante: restaurante,
      identificacao: linha['catraca'],
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
  expect(@funcionario.reload.catraca_em_operacao.identificacao).to eq(identificacao)
end

Then('a minha sessão não deve estar vinculada a nenhuma catraca') do
  expect(@funcionario.reload.catraca_em_operacao).to be_nil
end
