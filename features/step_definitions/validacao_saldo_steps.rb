Given('que um funcionário está logado no aplicativo') do
  @funcionario = Employee.create!(
    nome: 'Teste Funcionário',
    matricula_func: '123456',
    password: 'senha456'
  )
  login_as(@funcionario, scope: :employee)
end

Given('ele está na página de "Validação"') do
  visit validacao_path # substituir pela rota real, uma vez que ela for criada
end

Then('ele deve ver um painel intitulado {string}') do |titulo_catraca|
  expect(page).to have_content(titulo_catraca)
end

Then('uma sessão intitulada {string}') do |titulo_leitura|
  expect(page).to have_content(titulo_leitura)
end

When('o QR code analisado está associado a uma conta com saldo insuficiente') do
  @estudante = User.create!(
    nome: 'Teste Sem Saldo',
    matricula: '26100001',
    qr_code: 'QRCODE_001_SSALDO',
    saldo: 0.0
  )
end

When('o QR code analisado está associado a uma conta com saldo suficiente') do
  @estudante = User.create!(
    nome: 'Teste Com Saldo',
    matricula: '26100002',
    qr_code: 'QRCODE_002_CSALDO',
    saldo: 20.0
  )
end

When('o funcionário tenta validar o QR Code do estudante') do
  fill_in 'QR Code', with: @estudante.qr_code
  click_button 'Validar'
end

Then('o acesso da catraca para o restaurante deve ser {string} para a próxima passagem') do |status|
  expect(page).to have_css('.status_catraca', text: /#{status}/i)
end

Then('o preço da refeição deve ser descontado do saldo da conta do estudante') do
  @estudante.reload
  preco_refeicao = 5.0
  expect(@estudante.saldo).to eq(20.0 - preco_refeicao)
end