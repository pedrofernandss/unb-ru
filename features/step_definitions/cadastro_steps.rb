Given('que eu acesso a página de cadastro') do
  visit '/signup'
end

Then('ser redirecionado para a página {string}') do |caminho|
  expect(page).to have_current_path(caminho)
end

Then('eu devo ter meu cadastro realizado') do
  usuario_criado = User.find_by(matricula: "261234567")
  expect(usuario_criado).not_to be_nil
end