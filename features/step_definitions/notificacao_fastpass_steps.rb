Given('que o estudante está logado no aplicativo \(Teste FastPass\)') do
  @estudante = User.create!(
    nome: 'Estudante Com Muita Fome',
    matricula_disc: '261000004',
    password: 'senha123'
  )
  login_as(@estudante, scope: :user)
end

Given('ele se inscreveu no FastPass para a próxima refeição') do
  @refeicao = Meal.create!(
    tipo: 'Almoço',
    opcao_padrao: 'Peixe ao molho branco gratinado.',
    opcao_ovolacto: 'Ovos assados ao sugo',
    opcao_veg_estrito: 'Refogado de grão de bico',
    horario_inicio: Time.zone.parse('12:00:00'),
  )

  @inscricao = Subscription.create!(
    user: @estudante,
    meal: @refeicao,
    status: 'nao_sorteado'
  )
end

Given('ele acessa a página do Sorteio do FastPass') do
  visit fastpass_path
end

When('a refeição não será servida dentro dos próximos 60 minutos') do
  horario_distante = @refeicao.horario_inicio - 2.hours
  travel_to(horario_distante)
  visit current_path
end

Then('o estudante deve ver um aviso dizendo: {string}') do |mensagem|
  expect(page).to have_content(mensagem)
end

When('a refeição será servida dentro dos próximos 60 minutos') do
  @inscricao.update!(status: 'sorteado_ganhou')
  horario_proximo = @refeicao.horario_inicio - 30.minutes
  travel_to(horario_proximo)

  visit current_path
end

Then('o estudante deve ver uma mensagem dizendo: {string}') do |mensagem_resultado|
  expect(page).to have_content(mensagem_resultado)
end

Then('um painel com o resultado \({string} ou {string})') do |msg_ganhou, msg_perdeu|
  expect(page).to have_css('#painel-resultado-fastpass')
  expect(page).to have_content(msg_ganhou).or have_content(msg_perdeu)
end

After do
  # travel_back
  # Libera o tempo do sistema (adicionar TimeHelpers)
end
