# Steps da issue #15 - Validação Rigorosa FastPass
# O helper valor_em_reais vive em features/support/helpers.rb

Given('a minha sessão está vinculada à catraca {string}') do |identificacao|
  @catraca = Catraca.find_by!(identificacao: identificacao)
  @funcionario.update!(catraca_em_operacao: @catraca)
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
    SorteioFastpass.create!(
      user: estudante,
      turno: turno,
      janela_inicio: inicio,
      janela_fim: fim,
      contemplado: true
    )
  end
end

Given('o estudante de matrícula {string} possui saldo de {string}') do |matricula, valor|
  User.find_by!(matricula: matricula).update!(saldo: valor_em_reais(valor))
end

# A leitura é disparada com um horário fixo para que o critério de janela seja determinístico.
When('a catraca lê o QR Code da matrícula {string} às {string}') do |matricula, horario|
  ValidacaoDeAcesso.processar!(
    catraca: @catraca,
    matricula: matricula,
    lido_em: Time.zone.parse(horario)
  )
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
