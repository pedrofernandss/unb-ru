class CreateTransacoes < ActiveRecord::Migration[8.1]
  def change
    create_table :transacoes do |t|
      t.references :aluno, null: false, foreign_key: { to_table: :users }
      # Opcional: uma recarga de saldo não acontece em um restaurante.
      t.references :restaurante, null: true, foreign_key: true
      # Opcional: preenchido quando a transação paga uma refeição.
      t.references :refeicao, null: true, foreign_key: true
      t.datetime :data_hora, null: false
      t.string :tipo, null: false
      t.decimal :valor, precision: 10, scale: 2, null: false

      t.timestamps
    end

    add_index :transacoes, [ :aluno_id, :data_hora ]
  end
end
