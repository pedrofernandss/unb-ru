class AddNumeroDePisosToRestaurantes < ActiveRecord::Migration[8.1]
  def up
    add_column :restaurantes, :numero_de_pisos, :integer, null: false, default: 1
    change_column_null :restaurantes, :campus_id, true
    add_index :restaurantes, :nome, unique: true

    # Bancos já semeados têm catracas acima do piso 1; sem isso elas ficariam fora do restaurante.
    execute <<~SQL
      UPDATE restaurantes
      SET numero_de_pisos = (SELECT MAX(piso) FROM catracas WHERE catracas.restaurante_id = restaurantes.id)
      WHERE EXISTS (SELECT 1 FROM catracas WHERE catracas.restaurante_id = restaurantes.id)
    SQL
  end

  def down
    remove_index :restaurantes, :nome
    change_column_null :restaurantes, :campus_id, false
    remove_column :restaurantes, :numero_de_pisos
  end
end
