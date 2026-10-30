# Dados iniciais do UnB-RU. Idempotente: pode ser executado várias vezes
# (bin/rails db:seed) sem duplicar registros.

puts "Semeando universidade, campi e restaurantes..."
unb = Universidade.find_or_create_by!(nome: "Universidade de Brasília")

restaurantes = {
  "Darcy Ribeiro" => "RU Darcy Ribeiro",
  "Gama" => "RU Gama",
  "Ceilândia" => "RU Ceilândia",
  "Planaltina" => "RU Planaltina"
}.map do |nome_campus, nome_restaurante|
  campus = unb.campi.find_or_create_by!(nome: nome_campus)
  Restaurante.find_or_create_by!(campus: campus) { |r| r.nome = nome_restaurante }
end

puts "Semeando catracas..."
restaurantes.each_with_index do |restaurante, indice|
  pisos = indice.zero? ? [ 1, 1, 2, 2 ] : [ 1, 1 ]
  pisos.each_with_index do |piso, i|
    restaurante.catracas.find_or_create_by!(numero: i + 1) { |c| c.piso = piso }
  end
end

puts "Semeando tipos de refeição..."
tipos = {
  "cafe_da_manha" => [ "Café da manhã", "07:00", "09:30" ],
  "almoco" => [ "Almoço", "11:00", "14:30" ],
  "jantar" => [ "Jantar", "17:00", "19:30" ]
}.to_h do |chave, (nome, inicio, fim)|
  [ chave, TipoRefeicao.find_or_create_by!(nome: nome) { |t| t.hora_inicio = inicio; t.hora_fim = fim } ]
end

puts "Semeando usuários (senha de todos: senha123)..."
[
  { nome: "Administrador do Sistema", matricula: "1000001", perfil: :administrador },
  { nome: "Funcionário do RU", matricula: "1984201", perfil: :funcionario },
  { nome: "Aluno de Exemplo", matricula: "2023123456", perfil: :aluno, saldo: 50 }
].each do |atributos|
  User.find_or_create_by!(matricula: atributos[:matricula]) do |u|
    u.assign_attributes(atributos.merge(password: "senha123"))
  end
end

puts "Semeando cardápio da semana atual a partir de cardapio.json..."
cardapio = JSON.parse(Rails.root.join("cardapio.json").read)
dias = %w[segunda-feira terca-feira quarta-feira quinta-feira sexta-feira sabado domingo]
inicio_da_semana = Date.current.beginning_of_week(:monday)

restaurantes.each do |restaurante|
  dias.each_with_index do |dia, deslocamento|
    cardapio.fetch(dia, {}).each do |chave_refeicao, pratos|
      tipo = tipos[chave_refeicao] or next
      prefixo = chave_refeicao == "cafe_da_manha" ? "complemento" : "prato_principal"

      restaurante.refeicoes.find_or_create_by!(tipo_refeicao: tipo, data: inicio_da_semana + deslocamento) do |r|
        r.opcao_normal = pratos["#{prefixo}_padrao"]
        r.opcao_ovolactovegetariana = pratos["#{prefixo}_ovolactovegetariano"]
        r.opcao_vegetariana_estrita = pratos["#{prefixo}_vegetariano_estrito"]
      end
    end
  end
end

puts "Pronto: #{Universidade.count} universidade, #{Campus.count} campi, #{Restaurante.count} restaurantes, " \
     "#{Catraca.count} catracas, #{TipoRefeicao.count} tipos de refeição, #{Refeicao.count} refeições, #{User.count} usuários."
