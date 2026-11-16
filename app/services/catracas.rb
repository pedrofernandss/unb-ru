module Catracas
  class Simulada
    def disponivel? = true

    def enviar(catraca:, comando:, evento_id:)
      Rails.logger.info("Simulador de catraca #{catraca.id}: #{comando}, evento #{evento_id}")
      true
    end
  end

  class Indisponivel
    def disponivel? = false
    def enviar(catraca:, comando:, evento_id:) = false
  end

  def self.dispositivo
    Rails.configuration.x.dispositivo_catraca || (Rails.env.local? ? Simulada.new : Indisponivel.new)
  end
end
