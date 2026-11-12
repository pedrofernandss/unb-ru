class ValidacaoController < ApplicationController
  before_action :verificar_funcionario!

  def new
    @status_catraca = flash[:status_catraca] || 'Aguardando análise'
    @mensagem_status = flash[:mensagem_status]
    @estudante = User.find_by(id: flash[:estudante_id]) if flash[:estudante_id].present?
  end

  def create
    estudante = User.aluno.find_by(qr_code: params[:qr_code].to_s.strip)

    if estudante&.debitar_refeicao!
      flash[:status_catraca] = 'Liberado'
      flash[:mensagem_status] = 'Acesso permitido. Refeição debitada com sucesso.'
    else
      flash[:status_catraca] = 'Bloqueado'
      flash[:mensagem_status] = estudante ? 'Saldo insuficiente.' : 'QR Code inválido ou aluno não encontrado.'
    end

    flash[:estudante_id] = estudante&.id
    redirect_to validacao_path
  end

  private

  def verificar_funcionario!
    unless current_user&.funcionario?
      redirect_to root_path, alert: 'Acesso não autorizado.'
    end
  end
end
