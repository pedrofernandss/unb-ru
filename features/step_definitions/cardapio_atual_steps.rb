Given("que o estudante está logado no aplicativo") do
  @estudante = User.create!(
    nome: "Estudante Com Fome",
    matricula: "26100003",
    password: "senha123"
  )
  login_as(@estudante, scope: :user)
end

Given("ele está na página inicial") do
  visit "/home"
end

Then("ele deve ver uma seção intitulada {string}") do |titulo_cardapio|
  expect(page).to have_content(titulo_cardapio)
end

Then("ele deve ver um botão intitulado {string}") do |botao_cardapio|
  expect(page).to have_button(botao_cardapio)
end

When("nenhuma refeição está sendo servida") do
  Refeicao.destroy_all
end

When("uma refeição está sendo servida") do
  universidade = Universidade.find_or_create_by!(nome: "Universidade de Brasília")
  campus = universidade.campi.find_or_create_by!(nome: "Darcy Ribeiro")
  restaurante = Restaurante.find_or_create_by!(campus: campus) { |r| r.nome = "RU Darcy Ribeiro" }

  tipo_almoco = TipoRefeicao.find_or_create_by!(nome: "Almoço") do |t|
    t.hora_inicio = "11:00"
    t.hora_fim = "14:30"
  end

  travel_to Time.zone.local(2026, 11, 14, 12, 30, 0)

  @refeicao = Refeicao.create!(
    restaurante: restaurante,
    tipo_refeicao: tipo_almoco,
    data: Date.new(2026, 11, 14),
    opcao_normal: "Peixe ao molho branco gratinado.",
    opcao_ovolactovegetariana: "Ovos assados ao sugo",
    opcao_vegetariana_estrita: "Refogado de grão de bico"
  )
end

When("estudante aperta o botão {string}") do |botao_cardapio|
  click_button botao_cardapio
end

Then("ele deve ver um erro dizendo: {string}") do |mensagem_erro|
  expect(page).to have_content(mensagem_erro)
end

Then('ele deve ver qual refeição está sendo servida \(café da manhã, almoço, jantar\)') do
  expect(page).to have_content(@refeicao.tipo_refeicao.nome)
end

Then('todas as opções da refeição \(padrão, ovolactovegetariano e vegetariano estrito\)') do
  expect(page).to have_content(@refeicao.opcao_normal)
  expect(page).to have_content(@refeicao.opcao_ovolactovegetariana)
  expect(page).to have_content(@refeicao.opcao_vegetariana_estrita)
end
