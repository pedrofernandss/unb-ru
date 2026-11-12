class ValidacaoController < ApplicationController
  before_action :authenticate_user!
  before_action :verificar_funcionario!

  def new
    @status_catraca = 'Aguardando leitura'
  end

  def create
    estudante = User.estudante.find_by(qr_code: params[:qr_code])

    if estudante&.debitar_refeicao!
      @status_catraca = 'Liberado'
    else
      @status_catraca = 'Bloqueado'
    end

    render :new, status: :unprocessable_entity
  end

  private

  def verificar_funcionario!
    redirect_to root_path, alert: 'Acesso não autorizado.' unless current_user.funcionario?
  end
end