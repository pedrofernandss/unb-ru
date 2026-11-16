class AddTarifaToTiposRefeicao < ActiveRecord::Migration[8.1]
  # O preço é atributo do turno: o café da manhã custa menos que almoço e jantar,
  # como o próprio db/seeds.rb já registrava no histórico do aluno de exemplo.
  # O default repete o valor único que valia antes desta migration, para que
  # turnos já cadastrados continuem cobrando o mesmo.
  def change
    add_column :tipos_refeicao, :tarifa, :decimal, precision: 10, scale: 2, null: false, default: "4.5"
    add_check_constraint :tipos_refeicao, "tarifa > 0", name: "tipo_refeicao_tarifa_positiva"
  end
end
