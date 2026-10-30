class CreateRestaurantes < ActiveRecord::Migration[8.1]
  def change
    create_table :restaurantes do |t|
      # Um campus possui no máximo um restaurante.
      t.references :campus, null: false, foreign_key: true, index: { unique: true }
      t.string :nome, null: false

      t.timestamps
    end
  end
end
