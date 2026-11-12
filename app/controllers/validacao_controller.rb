class ValidacaoController < ApplicationController
  before_action :verificar_funcionario!

  def new
    @status_catraca = "Aguardando análise"
    @estudante = nil
  end

  def create
    estudante = User.aluno.find_by(qr_code: params[:qr_code])

    if estudante&.debitar_refeicao!
      @status_catraca = "Liberado"
      @mensagem = "Acesso Liberado"
    else
      @status_catraca = "Bloqueado"
      @mensagem = "Acesso Bloqueado (Falta de saldo)"
    end
    render :new, status: :ok
  end

  private

  def verificar_funcionario!
    redirect_to root_path, alert: "Acesso não autorizado." unless current_user.funcionario?
  end
end
