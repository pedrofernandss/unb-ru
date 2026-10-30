class CreateCampi < ActiveRecord::Migration[8.1]
  def change
    create_table :campi do |t|
      t.references :universidade, null: false, foreign_key: true
      t.string :nome, null: false

      t.timestamps
    end

    add_index :campi, [ :universidade_id, :nome ], unique: true
  end
end
