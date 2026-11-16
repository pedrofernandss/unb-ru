Given('que eu estou na página inicial') do
  visit '/home'
end

Given('que eu estou logado como um estudante') do
  @estudante = User.create!(
    nome: 'Estudante',
    matricula: '190012345',
    password: 'password123'
  )
  login_as(@estudante, scope: :user)
end

Given('que eu sou um estudante recém-cadastrado sem histórico') do
  @estudante = User.create!(
    nome: 'Calouro',
    matricula: '200054321',
    password: 'password123'
  )
  login_as(@estudante, scope: :user)
end

Given('eu possuo o seguinte histórico de uso no Restaurante Universitário:') do |table|
  table.hashes.each do |linha|
    nome_restaurante, piso = linha['restaurante'].split(' - Piso ')
    restaurante = restaurante_de_teste(nome_restaurante)
    catraca = piso && restaurante.catracas.find_or_create_by!(piso: piso.to_i) do |c|
      c.numero = restaurante.catracas.count + 1
    end

    @estudante.transacoes.create!(
      data_hora: Time.zone.strptime(linha['data_hora'], '%d/%m/%Y %H:%M'),
      tipo: linha['tipo'],
      restaurante: restaurante,
      catraca: catraca,
      metodo: linha['metodo'],
      valor: linha['valor'].to_d
    )
  end

  travel_to(@estudante.transacoes.maximum(:data_hora) + 10.minutes)
end

When('eu clico no botão {string} no topo da página') do |texto_botao|
  within('header') do
    click_on texto_botao
  end
end

Then('eu devo ser redirecionado para a página {string}') do |caminho|
  expect(page).to have_current_path(caminho)
end

Then(/^eu devo ver um card com o (?!.* vazio$)(.*)$/) do |conteudo_card|
  expect(page).to have_css('.card', text: /#{conteudo_card}/i)
end

Then('eu devo ver uma tabela contendo os cabeçalhos {string}, {string}, {string}, {string}, {string} e {string}') do |c1, c2, c3, c4, c5, c6|
  within('table thead') do
    expect(page).to have_selector('th', text: c1)
    expect(page).to have_selector('th', text: c2)
    expect(page).to have_selector('th', text: c3)
    expect(page).to have_selector('th', text: c4)
    expect(page).to have_selector('th', text: c5)
    expect(page).to have_selector('th', text: c6)
  end
end

Then('a tabela deve exibir a linha com {string}, {string}, {string}, {string}, {string} e {string}') do |data, evento, restaurante, metodo, valor, comprovante|
  within('table tbody') do
    linha = find('tr', text: data)
    expect(linha).to have_content(evento)
    expect(linha).to have_content(restaurante)
    expect(linha).to have_content(metodo)
    expect(linha).to have_content(valor)
    expect(linha).to have_content(comprovante)
  end
end

Then(/^eu devo ver um card com o (.*) vazio$/) do |nome_do_card|
  within('.card', text: /#{nome_do_card}/i) do
    texto = page.text
    expect(texto).to match(/R\$ 0,00|0\b/i)
  end
end

Then('a tabela deve estar vazia') do
  within('table') do
    tbody = find('tbody')
    expect(tbody).to have_no_selector('tr')
  end
end
