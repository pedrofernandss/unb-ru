ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
abort("RSpec não pode executar em produção") if Rails.env.production?
require "rspec/rails"

ActiveRecord::Migration.maintain_test_schema!

module DadosDeTeste
  def criar_usuario(perfil: :aluno, saldo: 18)
    User.create!(nome: "Usuário Teste", matricula: SecureRandom.random_number(10**9).to_s.rjust(9, "0"),
                 password: "senha123", perfil: perfil, saldo: saldo)
  end

  def criar_restaurante(nome: "RU Teste")
    universidade = Universidade.find_or_create_by!(nome: "UnB")
    campus = universidade.campi.create!(nome: "Campus #{SecureRandom.hex(4)}")
    Restaurante.create!(nome: nome, campus: campus)
  end

  def entrar_como(usuario)
    post login_path, params: { matricula: usuario.matricula, senha: "senha123" }
  end
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.include DadosDeTeste
  config.include ActiveSupport::Testing::TimeHelpers
  config.after { travel_back }
  config.order = :random
end
