class CreateHistoricosCatraca < ActiveRecord::Migration[8.1]
  def change
    create_table :historicos_catraca do |t|
      t.references :catraca, null: false, foreign_key: true
      t.references :aluno, null: false, foreign_key: { to_table: :users }
      t.datetime :data_hora, null: false

      t.timestamps
    end

    add_index :historicos_catraca, [ :catraca_id, :data_hora ]
    add_index :historicos_catraca, [ :aluno_id, :data_hora ]
  end
end
