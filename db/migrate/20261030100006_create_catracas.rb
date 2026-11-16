class CreateCatracas < ActiveRecord::Migration[8.1]
  def change
    create_table :catracas do |t|
      t.references :restaurante, null: false, foreign_key: true
      # Funcionário responsável: no máximo uma catraca por funcionário. Fica
      # opcional para que a catraca exista antes de alguém assumi-la (US05).
      t.references :funcionario, null: true, foreign_key: { to_table: :users }, index: { unique: true }
      t.integer :numero, null: false
      t.integer :piso, null: false, default: 1

      t.timestamps
    end

    add_index :catracas, [ :restaurante_id, :numero ], unique: true
  end
end
