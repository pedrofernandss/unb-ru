class CatracaFisicaFake
  def self.comandos = (@comandos ||= {})
  def self.ultimo_comando(catraca) = comandos[catraca.id]
  def disponivel? = true

  def enviar(catraca:, comando:, evento_id:)
    self.class.comandos[catraca.id] = comando
    true
  end
end

Before do
  CatracaFisicaFake.comandos.clear
  Rails.configuration.x.dispositivo_catraca = CatracaFisicaFake.new
end
After { Rails.configuration.x.dispositivo_catraca = nil }
