Given('o sistema possui os seguintes time-frames de FastPass ativos para o {string}:') do |turno, table|
  table.hashes.each do |linha|
    FastpassSlot.create!(
      turno: turno,
      horario: linha['horario'],
      nome_lote: linha['lote'],
      ativo: true
    )
  end
end

Given('eu já estou inscrito no sorteio do {string} para o horário {string}') do |turno, horario|
  slot = FastpassSlot.find_by(turno: turno, horario: horario)
  InscricaoFastpass.create!(
    user: @estudante,
    fastpass_slot: slot
  )
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