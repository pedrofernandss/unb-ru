Given('que eu estou logado como um administrador') do
  @administrador = User.create!(
    nome: 'Administrador',
    matricula: '1083921',
    password: 'password123',
    perfil: 'administrador'
  )
  login_as(@administrador, scope: :user)
end

Given('existe o restaurante {string} com {int} pisos e as seguintes catracas:') do |nome, pisos, table|
  restaurante = Restaurante.create!(nome: nome, numero_de_pisos: pisos)
  table.hashes.each do |linha|
    restaurante.catracas.create!(nome: linha['nome'], piso: linha['piso'].to_i)
  end
end

Given('que eu acesso a página de gestão de restaurantes') do
  visit '/admin/restaurantes'
end

When('eu tento acessar a página de gestão de restaurantes') do
  visit '/admin/restaurantes'
end

When('eu seleciono {string} no campo {string}') do |opcao, campo|
  select opcao, from: campo
end

When('eu clico no botão {string} do restaurante {string}') do |texto_botao, restaurante|
  within('.restaurante', text: restaurante) do
    click_button texto_botao
  end
end

When('eu clico no botão {string} da catraca {string}') do |texto_botao, catraca|
  within('.catraca', text: catraca) do
    click_button texto_botao
  end
end

Then('o restaurante {string} deve aparecer na lista de unidades cadastradas') do |restaurante|
  expect(page).to have_css('.restaurante', text: restaurante)
end

Then('a catraca {string} deve aparecer no piso {int} do restaurante {string}') do |catraca, piso, restaurante|
  within('.restaurante', text: restaurante) do
    within(".piso-#{piso}") do
      expect(page).to have_css('.catraca', text: catraca)
    end
  end
end

Then('a catraca {string} não deve aparecer no restaurante {string}') do |catraca, restaurante|
  within('.restaurante', text: restaurante) do
    expect(page).not_to have_css('.catraca', text: catraca)
  end
end
