class CreateRecargas < ActiveRecord::Migration[8.1]
  def change
    create_table :recargas do |t|
      t.references :aluno, null: false, foreign_key: { to_table: :users }
      t.string :chave, null: false
      t.integer :quantidade, null: false
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.string :metodo, null: false
      t.string :status, null: false, default: "pendente"
      t.references :transacao, foreign_key: true, index: { unique: true }
      t.timestamps
    end
    add_index :recargas, :chave, unique: true
    add_check_constraint :recargas, "quantidade BETWEEN 1 AND 50", name: "recarga_quantidade_valida"
    add_check_constraint :recargas, "valor > 0", name: "recarga_valor_positivo"
  end
end
