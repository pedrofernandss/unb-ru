class AddDetalhesToHistoricosCatraca < ActiveRecord::Migration[8.1]
  def change
    add_column :historicos_catraca, :modo_validacao, :string, default: "Comum"
    add_column :historicos_catraca, :tarifa, :decimal, precision: 8, scale: 2, default: 4.50
    add_column :historicos_catraca, :status, :string, default: "Liberado"
  end
end
