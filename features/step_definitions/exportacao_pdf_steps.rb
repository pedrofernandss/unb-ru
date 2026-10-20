# Steps da issue #11 - Exportação em PDF do Histórico do Estudante

Given('eu possuo os seguintes lançamentos no meu histórico:') do |table|
  table.hashes.each do |linha|
    restaurante = Restaurante.find_or_create_by!(nome: linha['restaurante'])
    Lancamento.create!(
      user: @estudante,
      restaurante: restaurante,
      ocorrido_em: DateTime.strptime(linha['data_hora'], '%d/%m/%Y %H:%M'),
      evento: linha['evento'],
      valor: linha['valor'].to_d
    )
  end
end

Given('que eu acesso a página de extrato de refeições') do
  visit '/extrato'
end

When('eu filtro o período de {string} até {string}') do |inicio, fim|
  within('.filtros-de-auditoria') do
    fill_in 'Data inicial', with: inicio
    fill_in 'Data final', with: fim
    click_on 'Aplicar filtros'
  end
end

# O PDF não é renderizado no navegador: olhamos a resposta que o Rails devolveu.
Then('eu devo receber um arquivo PDF chamado {string}') do |nome_arquivo|
  expect(page.response_headers['Content-Type']).to eq('application/pdf')
  expect(page.response_headers['Content-Disposition']).to include(nome_arquivo)
end

Then('o PDF deve conter o cabeçalho {string}') do |cabecalho|
  pdf = PDF::Reader.new(StringIO.new(page.body))
  expect(pdf.pages.first.text).to include(cabecalho)
end

Then('nenhum arquivo PDF deve ser gerado') do
  expect(page.response_headers['Content-Type']).not_to include('application/pdf')
end
