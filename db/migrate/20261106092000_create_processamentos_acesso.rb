class CreateProcessamentosAcesso < ActiveRecord::Migration[8.1]
  def change
    create_table :processamentos_acesso do |t|
      t.string :chave, null: false
      t.references :catraca, null: false, foreign_key: true
      t.references :aluno, foreign_key: { to_table: :users }
      t.references :historico_catraca, foreign_key: { to_table: :historicos_catraca }, index: { unique: true }
      t.references :transacao, foreign_key: true, index: { unique: true }
      t.string :matricula, null: false
      t.string :modo, null: false
      t.boolean :liberado, null: false, default: false
      t.string :motivo, null: false
      t.datetime :data_hora, null: false
      t.datetime :comando_enviado_em
      t.timestamps
    end
    add_index :processamentos_acesso, :chave, unique: true
  end
end
