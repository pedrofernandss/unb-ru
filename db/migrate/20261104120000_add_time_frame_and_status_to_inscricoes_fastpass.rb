class AddTimeFrameAndStatusToInscricoesFastpass < ActiveRecord::Migration[8.1]
  def up
    # Inscrições anteriores não têm janela e não há como saber qual o aluno teria
    # escolhido, então são apagadas de propósito. Sem isso, o null: false abaixo
    # quebra em qualquer banco que já tenha inscrições.
    execute "DELETE FROM inscricoes_fastpass"

    # A inscrição é feita em uma janela do turno (US13).
    add_reference :inscricoes_fastpass, :time_frame, null: false, foreign_key: true

    # Restaurante e refeição deixam de ser obrigatórios: a inscrição não depende
    # do cardápio do dia. As colunas ficam para uso futuro (ex.: validação na catraca).
    change_column_null :inscricoes_fastpass, :refeicao_id, true
    change_column_null :inscricoes_fastpass, :restaurante_id, true

    # Resultado do sorteio, preenchido pela #14 e lido pela #15.
    add_column :inscricoes_fastpass, :status, :string, null: false, default: "inscrito"
  end

  # Voltar exigiria refeicao_id em todas as inscrições, mas no fluxo novo ela é sempre
  # nula: o rollback quebraria no meio. Melhor falhar logo, com o motivo.
  def down
    raise ActiveRecord::IrreversibleMigration,
          "inscrições novas não têm refeicao_id, que voltaria a ser obrigatório"
  end
end
