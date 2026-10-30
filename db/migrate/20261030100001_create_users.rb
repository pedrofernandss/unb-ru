# Aluno e Funcionário do MER compartilham matrícula, nome e autenticação,
# então ficam numa única tabela diferenciada pelo perfil.
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :nome, null: false
      t.string :matricula, null: false
      t.string :password_digest, null: false
      t.string :perfil, null: false, default: "aluno"
      t.decimal :saldo, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end

    add_index :users, :matricula, unique: true
    add_index :users, :perfil
  end
end
