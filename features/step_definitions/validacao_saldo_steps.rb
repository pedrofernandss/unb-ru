require "bigdecimal"

Given("que um funcionário está logado no aplicativo") do
  @funcionario = User.find_or_create_by!(matricula: "1234567") do |u|
    u.nome = "Teste Funcionário"
    u.password = "senha1234"
    u.password_confirmation = "senha1234"
    u.perfil = :funcionario
  end

  visit login_path
  fill_in "Matrícula", with: @funcionario.matricula
  fill_in "Senha", with: "senha1234"
  click_button "Entrar"
end

Given("ele está operando a catraca {string}") do |numero_catraca|
  universidade = Universidade.find_or_create_by!(nome: "Universidade de Brasília")
  campus = Campus.find_or_create_by!(nome: "Darcy Ribeiro", universidade: universidade)
  restaurante = Restaurante.find_or_create_by!(nome: "RU Darcy Ribeiro", campus: campus)

  @catraca = Catraca.find_or_create_by!(numero: numero_catraca, restaurante: restaurante) do |c|
    c.piso = 1
    c.online = true
  end
  @catraca.update!(piso: @catraca.piso.presence || 1, online: true)

  # Garante os turnos cadastrados com as tarifas do PR #30
  TipoRefeicao.find_or_create_by!(nome: "Café da manhã") do |t|
    t.hora_inicio = "07:00"
    t.hora_fim = "09:30"
    t.tarifa = BigDecimal("2.50")
  end
  @turno_atual = TipoRefeicao.find_or_create_by!(nome: "Almoço") do |t|
    t.hora_inicio = "11:00"
    t.hora_fim = "14:30"
    t.tarifa = BigDecimal("4.50")
  end

  # Congela no horário do almoço por padrão (12:00), salvo se outro horário já foi definido
  travel_to Time.zone.parse("2026-10-16 12:00:00") unless @horario_definido

  # Seleciona o restaurante e a catraca pelos radio buttons do formulário oficial
  visit configuracao_de_ponto_path
  within(".unidades-operacionais") do
    choose restaurante.nome
  end
  within(".catracas-fisicas") do
    choose @catraca.identificacao
  end
  click_button "Confirmar e Iniciar Operação"
end

Given('ele está na página de {string}') do |nome_pagina|
  case nome_pagina
  when "Validação"
    visit validacao_path
  when "Histórico Local"
    visit historico_local_path
  else
    raise "Página desconhecida: #{nome_pagina}"
  end
end

Given("existe um aluno cadastrado com matrícula {string} e QR Code {string}") do |matricula, qr_code|
  @estudante = User.find_or_create_by!(matricula: matricula) do |u|
    u.nome = "Discente Teste"
    u.password = "senha1234"
    u.password_confirmation = "senha1234"
    u.perfil = :aluno
    u.saldo = BigDecimal("0.00")
  end
  @estudante.update!(qr_code: qr_code)
end

Given("que o aluno possui saldo de R$ {string}") do |valor_str|
  @saldo_inicial = BigDecimal(valor_str.tr(",", "."))
  @estudante.update!(saldo: @saldo_inicial)
end

When("o funcionário tenta validar o QR Code do estudante") do
  fill_in "QR Code", with: @estudante.qr_code
  click_button "Simular"
end

Then(/^ele deve ver um painel intitulado "([^:]+):\s*([^"]+)"$/) do |titulo, numero_catraca|
  within("#painel-catraca") do
    expect(page).to have_content(titulo)
    expect(page).to have_content(numero_catraca)
  end
end

Then("uma seção intitulada {string}") do |secao|
  expect(page).to have_content(secao)
end

Then("o acesso da catraca para o restaurante deve ser bloqueado por {string}") do |motivo|
  within("#status-acesso") do
    expect(page).to have_content("Bloqueado")
    expect(page).to have_content(/#{Regexp.escape(motivo)}/i)
  end
end

Then("o acesso da catraca para o restaurante deve ser liberado") do
  within("#status-acesso") do
    expect(page).to have_content("Liberado")
  end
end

Then("o saldo do aluno deve permanecer em R$ {string}") do |valor_str|
  @estudante.reload
  expect(@estudante.saldo).to eq(BigDecimal(valor_str.tr(",", ".")))
end

Then("o valor da refeição deve ser descontado do saldo da conta do estudante") do
  @estudante.reload
  tarifa_esperada = TarifaRefeicao.do_turno(@turno_atual)
  expect(@estudante.saldo).to eq(@saldo_inicial - tarifa_esperada)
end

Then("não deve ser registrada nenhuma transação") do
  expect(Transacao.where(aluno: @estudante)).to be_empty
end

Then("deve ser registrada uma transação de débito") do
  tarifa_esperada = TarifaRefeicao.do_turno(@turno_atual)
  transacao = Transacao.where(aluno: @estudante, catraca: @catraca).order(:id).last

  expect(transacao).not_to be_nil
  expect(transacao.valor).to eq(-tarifa_esperada)
  expect(transacao.metodo).to eq("Comum")
end

Then("deve ser registrado no histórico da catraca {string} com status {string}") do |numero_catraca, status_esperado|
  catraca = Catraca.find_by!(numero: numero_catraca)
  historico = HistoricoCatraca.where(catraca: catraca, aluno: @estudante).order(:id).last

  expect(historico).not_to be_nil
  if status_esperado =~ /\ABloqueado \((.+)\)\z/i
    expect(historico.status).to eq("Bloqueado")
    expect(historico.motivo.downcase).to eq(Regexp.last_match(1).downcase)
  else
    expect(historico.status).to eq(status_esperado)
  end
end

Given("que o horário atual é {string} no turno {string} com tarifa de R$ {string}") do |hora, nome_turno, tarifa_str|
  @horario_definido = true
  @turno_atual = TipoRefeicao.find_by!(nome: nome_turno)
  @turno_atual.update!(tarifa: BigDecimal(tarifa_str.tr(",", ".")))
  travel_to Time.zone.parse("2026-10-16 #{hora}:00")
end

Given("que o horário atual é {string} fora de qualquer turno de refeição") do |hora|
  @horario_definido = true
  @turno_atual = nil
  travel_to Time.zone.parse("2026-10-16 #{hora}:00")
end

Then("o saldo do aluno deve ser atualizado para R$ {string}") do |valor_str|
  @estudante.reload
  expect(@estudante.saldo).to eq(BigDecimal(valor_str.tr(",", ".")))
end

Then("deve ser registrada uma transação de débito no valor de R$ {string}") do |valor_str|
  valor_esperado = BigDecimal(valor_str.tr(",", "."))
  transacao = Transacao.where(aluno: @estudante, catraca: @catraca).order(:id).last

  expect(transacao).not_to be_nil
  expect(transacao.valor).to eq(-valor_esperado)
end
