module Estudante
  # Inscrição do aluno logado em uma janela do FastPass (US13).
  class InscricoesFastpassController < BaseController
    def create
      time_frame = TimeFrame.find_by(id: params[:time_frame_id])
      return redirect_to(fastpass_path, alert: "Escolha um horário") unless time_frame

      inscricao = current_user.inscricoes_fastpass.new(time_frame: time_frame, data: Date.current)
      if inscricao.save
        redirect_to fastpass_path, notice: "Inscrição no sorteio realizada com sucesso"
      else
        redirect_to fastpass_path, alert: inscricao.errors.full_messages.to_sentence
      end
    end
  end
end
