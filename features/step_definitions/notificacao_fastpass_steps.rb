# O login usa o passo "que o estudante está logado no aplicativo" de
# cardapio_atual_steps.rb, e o relógio volta ao normal em support/tempo.rb.
# O início do turno é montado com a data de hoje: a coluna hora_inicio vem com a
# data 2000-01-01, e viajar para ela levaria o relógio para fora do dia da inscrição.
Given("ele se inscreveu no FastPass para a próxima refeição") do
  turno = TipoRefeicao.find_or_create_by!(nome: "Almoço") { |t| t.hora_inicio = "12:00"; t.hora_fim = "14:00" }
  janela = turno.time_frames.create!(inicio: "12:00", fim: "12:15")
  @inscricao = InscricaoFastpass.create!(aluno: @estudante, time_frame: janela, data: Date.current)
  @inicio_do_turno = Time.zone.parse(turno.hora_inicio.strftime("%H:%M"))
end

Given("ele acessa a página do Sorteio do FastPass") do
  visit fastpass_path
end

When("a refeição não será servida dentro dos próximos 60 minutos") do
  travel_to(@inicio_do_turno - 2.hours)
  visit current_path
end

Then("o estudante deve ver um aviso dizendo: {string}") do |mensagem|
  expect(page).to have_content(mensagem)
end

When("a refeição será servida dentro dos próximos 60 minutos") do
  @inscricao.update!(status: :contemplado)
  travel_to(@inicio_do_turno - 30.minutes)
  visit current_path
end

Then("o estudante deve ver uma mensagem dizendo: {string}") do |mensagem_resultado|
  expect(page).to have_content(mensagem_resultado)
end

Then('um painel com o resultado \({string} ou {string})') do |msg_ganhou, msg_perdeu|
  expect(page).to have_css("#painel-resultado-fastpass")
  expect(page).to have_content(msg_ganhou).or have_content(msg_perdeu)
end
