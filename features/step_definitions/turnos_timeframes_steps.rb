Given('existem os seguintes turnos cadastrados:') do |table|
  table.hashes.each do |linha|
    Turno.create!(nome: linha['turno'], inicio: linha['inicio'], fim: linha['fim'])
  end
end

Given('que eu acesso a página de turnos e time-frames') do
  visit '/admin/turnos'
end

When('eu tento acessar a página de turnos e time-frames') do
  visit '/admin/turnos'
end

Then('o turno {string} deve exibir o horário {string}') do |turno, horario|
  expect(page).to have_css('.turno', text: /#{turno}.*#{horario}/m)
end

Then('o turno {string} deve possuir {int} time-frames') do |turno, quantidade|
  within('.janelas-fastpass', text: turno) do
    expect(page).to have_css('.time-frame', count: quantidade)
  end
end

Then('o primeiro time-frame do turno {string} deve ser {string}') do |turno, horario|
  within('.janelas-fastpass', text: turno) do
    expect(all('.time-frame').first).to have_content(horario)
  end
end

Then('o último time-frame do turno {string} deve ser {string}') do |turno, horario|
  within('.janelas-fastpass', text: turno) do
    expect(all('.time-frame').last).to have_content(horario)
  end
end
