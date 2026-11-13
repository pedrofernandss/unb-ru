Given('existem os seguintes acessos registrados:') do |table|
  table.hashes.each do |linha|
    restaurante = Restaurante.find_by!(nome: linha['restaurante'])
    catraca = restaurante.catracas.find { |c| c.identificacao == linha['catraca'] }
    aluno = User.find_or_create_by!(matricula: linha['matricula']) do |u|
      u.nome = "Aluno #{linha['matricula']}"
      u.password = 'senha123'
    end

    HistoricoCatraca.create!(
      catraca: catraca,
      aluno: aluno,
      data_hora: Time.zone.strptime(linha['data_hora'], '%d/%m/%Y %H:%M'),
      modo_validacao: linha['modalidade'],
      status: linha['status'],
      tarifa: linha['valor'].to_d
    )
  end
end

Given('que eu acesso a página do relatório global') do
  visit '/admin/relatorio'
end

When('eu tento acessar a página do relatório global') do
  visit '/admin/relatorio'
end

Then('o relatório deve listar {int} acessos') do |quantidade|
  expect(page).to have_css('table.acessos tbody tr', count: quantidade)
end

Then('o relatório deve exibir o acesso da matrícula {string}') do |matricula|
  expect(page).to have_css('table.acessos tbody tr', text: matricula)
end

Then('o relatório não deve exibir o acesso da matrícula {string}') do |matricula|
  expect(page).not_to have_css('table.acessos tbody tr', text: matricula)
end

Then('o total de refeições servidas deve ser {string}') do |total|
  expect(page).to have_css('.total-refeicoes', text: total)
end

Then('a arrecadação global deve ser {string}') do |valor|
  expect(page).to have_css('.arrecadacao-global', text: valor)
end

Then('a consolidação do restaurante {string} deve exibir {int} acessos liberados e arrecadação de {string}') do |restaurante, acessos, valor|
  linha = find('table.consolidacao tbody tr', text: restaurante)
  expect(linha).to have_css('.acessos', text: acessos.to_s)
  expect(linha).to have_css('.arrecadacao', text: valor)
end

Then('eu devo receber um arquivo PDF') do
  expect(page.response_headers['Content-Type']).to include('application/pdf')
end
