# Steps da issue #15 - Validação Rigorosa FastPass
# O helper valor_em_reais vive em features/support/helpers.rb

Given('a minha sessão está vinculada à catraca {string}') do |identificacao|
  @catraca = Catraca.find_by!(numero: identificacao.split.last.to_i)
  visit '/configuracao-de-ponto'
  choose @catraca.restaurante.nome
  choose identificacao
  click_button 'Confirmar e Iniciar Operação'
end

# Cada linha é um estudante contemplado no sorteio e a janela de horário que ele tirou.
Given('o sorteio do FastPass do turno {string} teve o seguinte resultado:') do |turno, table|
  table.hashes.each do |linha|
    estudante = User.create!(
      matricula: linha['matricula'],
      nome: linha['estudante'],
      password: 'senha123'
    )
    inicio, fim = linha['janela'].split(' - ')
    tipo = TipoRefeicao.find_or_create_by!(nome: turno) { |t| t.hora_inicio = '11:00'; t.hora_fim = '14:00' }
    janela = tipo.time_frames.find_or_create_by!(inicio: inicio, fim: fim)
    InscricaoFastpass.create!(aluno: estudante, time_frame: janela, data: Date.current, status: :contemplado)
  end
end

Given('o estudante de matrícula {string} possui saldo de {string}') do |matricula, valor|
  User.find_by!(matricula: matricula).update!(saldo: valor_em_reais(valor))
end

# A leitura é disparada com um horário fixo para que o critério de janela seja determinístico.
When('a catraca lê o QR Code da matrícula {string} às {string}') do |matricula, horario|
  travel_to Time.zone.parse("#{Date.current.iso8601} #{horario}")
  fill_in 'QR Code', with: matricula
  choose 'Modo FastPass'
  click_button 'Validar'
end

Then('o terminal deve exibir {string}') do |resultado|
  within('.painel-de-resultado') do
    expect(page).to have_content(resultado)
  end
end

Then('a catraca física deve ser liberada') do
  expect(CatracaFisicaFake.ultimo_comando(@catraca)).to eq(:liberar)
end

Then('a catraca física não deve ser liberada') do
  expect(CatracaFisicaFake.ultimo_comando(@catraca)).to eq(:bloquear)
end

Then('o saldo do estudante de matrícula {string} deve ser {string}') do |matricula, valor|
  expect(User.find_by!(matricula: matricula).reload.saldo).to eq(valor_em_reais(valor))
end
