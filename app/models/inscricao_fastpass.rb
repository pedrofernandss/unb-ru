# Inscrição de um aluno no sorteio do FastPass em uma janela (time-frame) de um turno.
class InscricaoFastpass < ApplicationRecord
  self.table_name = "inscricoes_fastpass"

  # Resultado do sorteio: preenchido pela #14 e conferido na catraca pela #15.
  enum :status, { inscrito: "inscrito", contemplado: "contemplado", nao_contemplado: "nao_contemplado" },
       default: :inscrito

  belongs_to :aluno, class_name: "User", inverse_of: :inscricoes_fastpass
  belongs_to :time_frame
  # Opcionais desde a #13: a inscrição é feita por janela, sem depender do cardápio do dia.
  belongs_to :restaurante, optional: true
  belongs_to :refeicao, optional: true

  validates :data, presence: true
  validates :aluno_id, uniqueness: { scope: :refeicao_id }, if: :refeicao_id?
  validate :uma_por_turno_no_dia, if: -> { aluno && time_frame && data }

  private

  # A regra é uma inscrição por turno (Almoço, Jantar) no dia, e não por janela.
  def uma_por_turno_no_dia
    turno = time_frame.tipo_refeicao
    outras = InscricaoFastpass.joins(:time_frame)
                              .where(aluno: aluno, data: data, time_frames: { tipo_refeicao_id: turno.id })
                              .where.not(id: id)

    errors.add(:base, :ja_inscrito_no_turno, turno: turno.nome) if outras.exists?
  end
end
