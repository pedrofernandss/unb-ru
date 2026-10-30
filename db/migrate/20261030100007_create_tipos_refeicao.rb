class CreateTiposRefeicao < ActiveRecord::Migration[8.1]
  def change
    create_table :tipos_refeicao do |t|
      t.string :nome, null: false
      t.time :hora_inicio, null: false
      t.time :hora_fim, null: false

      t.timestamps
    end

    add_index :tipos_refeicao, :nome, unique: true
  end
end
