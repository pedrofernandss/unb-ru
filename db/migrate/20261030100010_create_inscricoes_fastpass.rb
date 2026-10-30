class CreateInscricoesFastpass < ActiveRecord::Migration[8.1]
  def change
    create_table :inscricoes_fastpass do |t|
      t.references :aluno, null: false, foreign_key: { to_table: :users }
      t.references :restaurante, null: false, foreign_key: true
      t.references :refeicao, null: false, foreign_key: true
      t.date :data, null: false
      t.time :hora_chegada

      t.timestamps
    end

    # Um aluno faz no máximo uma inscrição por refeição (que já tem dia e tipo).
    add_index :inscricoes_fastpass, [ :aluno_id, :refeicao_id ], unique: true
  end
end
