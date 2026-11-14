class ValidacaoController < ApplicationController
  before_action :verificar_funcionario!

  def new
    @catraca = catraca_atual
    @status_catraca = flash[:status_catraca] || "Aguardando análise"
    @mensagem_status = flash[:mensagem_status]
    @estudante = User.find_by(id: flash[:estudante_id]) if flash[:estudante_id].present?
  end

  def create
    @catraca = catraca_atual
    unless @catraca
      flash[:status_catraca] = "Erro: Acesso negado."
      flash[:mensagem_status] = "Nenhuma catraca selecionada na sessão."
      return redirect_to validacao_path
    end

    estudante = User.aluno.find_by(qr_code: params[:qr_code].to_s.strip)
    unless estudante
      flash[:status_catraca] = "Bloqueado"
      flash[:mensagem_status] = "QR Code inválido ou aluno não encontrado."
      return redirect_to validacao_path
    end

    evento = ValidacaoDeAcesso.processar!(
      catraca: @catraca,
      matricula: estudante.matricula,
      chave: SecureRandom.uuid,
      modo: "Comum"
    )

    if evento.liberado?
      flash[:status_catraca] = "Liberado"
      flash[:mensagem_status] = "Acesso permitido. Refeição debitada com sucesso."
    else
      flash[:status_catraca] = "Bloqueado"
      flash[:mensagem_status] = evento.motivo
    end

    flash[:estudante_id] = estudante&.id
    redirect_to validacao_path
  end

  private

  def catraca_atual
    @catraca_atual ||= Catraca.includes(:restaurante).find_by(id: session[:catraca_em_operacao_id])
  end

  def verificar_funcionario!
    redirect_to root_path, alert: "Acesso não autorizado." unless current_user&.funcionario?
  end
end
