module Estudante
  # Inscrição do aluno logado em uma janela do FastPass (US13).
  class InscricoesFastpassController < BaseController
    def create
      time_frame = TimeFrame.find_by(id: params[:time_frame_id])
      return redirect_to(fastpass_path, alert: "Escolha um horário") unless time_frame

      inscricao = current_user.inscricoes_fastpass.new(time_frame: time_frame, data: Date.current)
      if salvar(inscricao)
        redirect_to fastpass_path, notice: "Inscrição no sorteio realizada com sucesso"
      else
        redirect_to fastpass_path, alert: inscricao.errors.full_messages.to_sentence
      end
    end

    # Busca só entre as inscrições do aluno logado: a de outro aluno dá 404.
    # Depois do sorteio o resultado fica valendo. A regra fica aqui, e não no model,
    # para não travar o descarte em cascata quando o admin muda o horário do turno.
    def destroy
      inscricao = current_user.inscricoes_fastpass.find(params[:id])

      if inscricao.inscrito?
        inscricao.destroy!
        redirect_to fastpass_path, notice: "Inscrição cancelada"
      else
        redirect_to fastpass_path, alert: "O sorteio já foi realizado. Não é possível cancelar esta inscrição"
      end
    end

    private

    # Dois envios ao mesmo tempo passam os dois pela validação; o índice único do
    # banco barra o segundo, que recebe a mesma mensagem da validação.
    def salvar(inscricao)
      inscricao.save
    rescue ActiveRecord::RecordNotUnique
      inscricao.errors.add(:base, :ja_inscrito_no_turno, turno: inscricao.time_frame.tipo_refeicao.nome)
      false
    end
  end
end
