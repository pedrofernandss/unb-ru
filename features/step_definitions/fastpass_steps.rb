# As janelas do cenário não são regulares (falta 11:45 - 12:00), por isso são
# criadas diretamente, sem TipoRefeicao#configurar_time_frames. A coluna "lote"
# não é conferida por nenhum passo e não existe no modelo.
Given("o sistema possui os seguintes time-frames de FastPass ativos para o {string}:") do |turno, table|
  tipo = TipoRefeicao.find_or_create_by!(nome: turno) { |t| t.hora_inicio = "11:00"; t.hora_fim = "14:00" }
  table.hashes.each do |linha|
    inicio, fim = linha["horario"].split(" - ")
    tipo.time_frames.create!(inicio: inicio, fim: fim)
  end
end

Given("eu já estou inscrito no sorteio do {string} para o horário {string}") do |turno, horario|
  inicio = horario.split(" - ").first
  janela = TipoRefeicao.find_by!(nome: turno).time_frames.find { |tf| tf.inicio.strftime("%H:%M") == inicio }
  InscricaoFastpass.create!(aluno: @estudante, time_frame: janela, data: Date.current)
end

Given('que eu acesso a página de {string}') do |nome_pagina|
  case nome_pagina
  when "Sorteio FastPass"
    visit '/fastpass-home'
  when "Cadastro"
    visit '/signup'
  else
    visit '/home'
  end
end

When('eu seleciono a opção {string} para o turno {string}') do |opcao, turno|
  within(".secao-turno", text: turno) do
    choose opcao
  end
end

Then('a área do turno {string} deve exibir o status {string}') do |turno, status|
  within(".secao-turno", text: turno) do
    expect(page).to have_content(status)
  end
end