class AddIndiceUnicoToInscricoesFastpass < ActiveRecord::Migration[8.1]
  def change
    # O banco barra a mesma janela duas vezes no dia, mesmo com dois envios ao
    # mesmo tempo. A regra completa (uma por turno) fica na validação do model.
    add_index :inscricoes_fastpass, %i[aluno_id data time_frame_id], unique: true
  end
end
