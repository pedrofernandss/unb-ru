# Cobertura dos testes RSpec (Sprint 3). Precisa vir antes de carregar o app:
# o SimpleCov só enxerga as linhas executadas depois de iniciado.
require "simplecov"
SimpleCov.formatters = [ SimpleCov::Formatter::HTMLFormatter, SimpleCov::Formatter::JSONFormatter ]
SimpleCov.start "rails" do
  skip %r{\A(spec|test|features|config|db)/}
  group "Models", "app/models"
  group "Controllers", "app/controllers"
  group "Services", "app/services"
  group "Helpers", "app/helpers"
end

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

  # O nome do restaurante é único e as catracas dos specs ficam até o piso 3.
  def criar_restaurante(nome: "RU Teste #{SecureRandom.hex(4)}")
    universidade = Universidade.find_or_create_by!(nome: "UnB")
    campus = universidade.campi.create!(nome: "Campus #{SecureRandom.hex(4)}")
    Restaurante.create!(nome: nome, campus: campus, numero_de_pisos: 3)
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
