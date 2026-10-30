ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)

    fixtures :all

  end
end

class ActionDispatch::IntegrationTest
  def entrar_como(usuario)
    post "/teste/sessao", params: { user_id: usuario.id }
  end
end
