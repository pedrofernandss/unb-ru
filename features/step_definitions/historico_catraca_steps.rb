Given('que um funcionário está logado no aplicativo') do
  @funcionario = Employee.create!(
    nome: 'Teste Funcionário',
    matricula_func: '123456',
    password: 'senha456',
    catraca_atual: nil
  )
  login_as(@funcionario, scope: :employee)
end

Given('ele está na página de "Histórico Local"') do
  visit historico_local_path
end

When('o funcionário não está gerindo nenhuma catraca') do
  @funcionario.update!(catraca_atual: nil)
  visit current_path
end

Then('a página deve mostrar um texto dizendo {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

When('o funcionário está gerindo uma catraca') do
  @catraca = Catraca.create!(
    numero: '04',
    nome: 'Catraca 04',
    piso: 'Piso 2',
    status: 'Online',
    funcionario: @funcionario
  )
end

When('a catraca que ele está gerindo tem o seguinte histórico:') do |table|
  table.hashes.each do |linha|
    AcessoCatraca.create!(
      catraca: @catraca,
      data_hora: Time.zone.parse(linha['data_hora']),
      matricula_disc: linha['matricula_disc'],
      modo_validacao: linha['modo_validacao'],
      tarifa: linha['tarifa'].to_f,
      status: linha['status_catraca']
    )
  end
  visit current_path #Recarrega a página pra atualizar a tabela
end

Then('ele deve ver um texto dizendo a catraca que ele está gerenciando') do
  expect(page).to have_content(@catraca.numero)
end

Then('ele deve ver uma tabela com os cabeçalhos: {string}, {string}, {string}, {string} e {string}') do |cab1, cab2, cab3, cab4, cab5|
  within('table thead') do
    [cab1, cab2, cab3, cab4, cab5].each do |cabecalho|
      expect(page).to have_selector('th', text:cabecalho)
    end
  end
end

Then('a tabela deve conter a linha com: {string}, {string}, {string}, {string} e {string}') do |data_hora, matricula_disc, modo_validacao, tarifa, status_catraca|
  within('table tbody') do
    [data_hora, matricula_disc, modo_validacao, tarifa, status_catraca].each do |linha|
      expect(page).to have_content('tl', text:linha)
    end
  end
end
