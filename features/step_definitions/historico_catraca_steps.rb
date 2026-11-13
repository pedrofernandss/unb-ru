Given('que um funcionário está logado no aplicativo') do
  @funcionario = User.create!(
    nome: 'Teste Funcionário',
    matricula: '1234567',
    password: 'senha123',
    perfil: :funcionario,
    catraca: nil
  )
  login_as(@funcionario, scope: :user)
end

Given('ele está na página de "Histórico Local"') do
  visit historico_local_path
end

When('o funcionário não está gerindo nenhuma catraca') do
  @funcionario.update!(catraca: nil)
  visit current_path
end

Then('a página deve mostrar um texto dizendo {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

When('o funcionário está gerindo uma catraca') do
  universidade = Universidade.first || Universidade.create!(nome: 'Universidade de Brasília')
  campus = Campus.first || Campus.create!(nome: 'Darcy Ribeiro', universidade: universidade)
  restaurante = Restaurante.first || Restaurante.create!(nome: 'RU Darcy Ribeiro', campus: campus)

  @catraca = Catraca.create!(
    numero: '04',
    piso: '2',
    funcionario: @funcionario,
    restaurante: restaurante
  )
end

When('a catraca que ele está gerindo tem o seguinte histórico:') do |table|
  table.hashes.each_with_index do |linha, idx|
    aluno = User.find_or_create_by!(matricula: linha['matricula_disc']) do |u|
      u.nome = "Discente Teste #{idx + 1}"
      u.password = 'senha1234'
      u.password_confirmation = 'senha1234'
      u.perfil = :aluno
    end
    HistoricoCatraca.create!(
      catraca: @catraca,
      aluno: aluno,
      data_hora: Time.zone.parse(linha['data_hora']),
      modo_validacao: linha['modo_validacao'],
      tarifa: linha['tarifa'].gsub(/[^\d,]/, '').tr(',', '.').to_f,
      status: linha['status_catraca']
    )
  end
  visit current_path # Recarrega a página pra atualizar a tabela
end

Then('ele deve ver um texto dizendo a catraca que ele está gerenciando') do
  expect(page).to have_content(@catraca.numero)
end

Then('ele deve ver uma tabela com os cabeçalhos: {string}, {string}, {string}, {string} e {string}') do |cab1, cab2, cab3, cab4, cab5|
  within('table thead') do
    [ cab1, cab2, cab3, cab4, cab5 ].each do |cabecalho|
      expect(page).to have_selector('th', text: cabecalho)
    end
  end
end

Then('a tabela deve conter a linha com: {string}, {string}, {string}, {string} e {string}') do |data_hora, matricula_disc, modo_validacao, tarifa, status_catraca|
  within('table tbody') do
    [ data_hora, matricula_disc, modo_validacao, tarifa, status_catraca ].each do |valor|
      expect(page).to have_selector('td', text: valor)
    end
  end
end
