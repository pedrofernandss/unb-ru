class CreateCartoes < ActiveRecord::Migration[8.1]
  def change
    create_table :cartoes do |t|
      t.references :aluno, null: false, foreign_key: { to_table: :users }
      t.string :numero, null: false
      t.string :bandeira, null: false
      t.string :nome, null: false
      t.decimal :saldo, precision: 10, scale: 2, null: false, default: 0
      t.date :validade, null: false
      t.string :codigo_verificacao, null: false

      t.timestamps
    end

    add_index :cartoes, [ :aluno_id, :numero ], unique: true
  end
end
