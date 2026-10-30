class CreateRefeicoes < ActiveRecord::Migration[8.1]
  def change
    create_table :refeicoes do |t|
      t.references :restaurante, null: false, foreign_key: true
      t.references :tipo_refeicao, null: false, foreign_key: { to_table: :tipos_refeicao }
      t.date :data, null: false
      t.text :opcao_normal
      t.text :opcao_ovolactovegetariana
      t.text :opcao_vegetariana_estrita

      t.timestamps
    end

    add_index :refeicoes, [ :restaurante_id, :tipo_refeicao_id, :data ], unique: true
  end
end
