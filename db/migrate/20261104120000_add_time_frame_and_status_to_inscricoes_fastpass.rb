class AddTimeFrameAndStatusToInscricoesFastpass < ActiveRecord::Migration[8.1]
  def change
    # A inscrição é feita em uma janela do turno (US13).
    add_reference :inscricoes_fastpass, :time_frame, null: false, foreign_key: true

    # Restaurante e refeição deixam de ser obrigatórios: a inscrição não depende
    # do cardápio do dia. As colunas ficam para uso futuro (ex.: validação na catraca).
    change_column_null :inscricoes_fastpass, :refeicao_id, true
    change_column_null :inscricoes_fastpass, :restaurante_id, true

    # Resultado do sorteio, preenchido pela #14 e lido pela #15.
    add_column :inscricoes_fastpass, :status, :string, null: false, default: "inscrito"
  end
end
