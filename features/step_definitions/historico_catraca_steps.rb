# Steps definidos em validacao_saldo_steps.rb
# Given('que um funcionário está logado no aplicativo')

When('ele acessa a página de "Histórico Local"') do
  visit historico_local_path
end

When('o funcionário não está gerindo nenhuma catraca') do
  @funcionario.update!(catraca: nil)
end

Then('ele deve ser redirecionado para a configuração de ponto de acesso') do
  expect(page).to have_current_path(configuracao_de_ponto_path)
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
    piso: 2,
    online: true,
    funcionario: @funcionario,
    restaurante: restaurante
  )

  visit configuracao_de_ponto_path
  choose(restaurante.nome, allow_label_click: true)
  find("input[type='radio'][name*='catraca'][value='#{@catraca.id}']", visible: :all).click
  click_button 'Confirmar e Iniciar Operação'
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
      tarifa: BigDecimal(linha['tarifa'].gsub(/[^\d,]/, '').tr(',', '.')),
      status: linha['status_catraca'],
      motivo: linha['motivo']
    )
  end
end

Then('ele deve ver um texto dizendo a catraca que ele está gerenciando') do
  expect(page).to have_content(@catraca.numero)
end

Then('ele deve ver uma tabela com os cabeçalhos: {string}, {string}, {string}, {string}, {string} e {string}') do |cab1, cab2, cab3, cab4, cab5, cab6|
  within('table thead') do
    [ cab1, cab2, cab3, cab4, cab5, cab6 ].each do |cabecalho|
      expect(page).to have_selector('th', text: cabecalho)
    end
  end
end

Then('a tabela deve conter a linha com: {string}, {string}, {string}, {string}, {string} e {string}') do |data_hora, matricula_disc, modo_validacao, tarifa, status_catraca, motivo|
  within('table tbody') do
    [ data_hora, matricula_disc, modo_validacao, tarifa, status_catraca, motivo ].each do |valor|
      expect(page).to have_selector('td', text: valor)
    end
  end
end
