class UsersController < ApplicationController
  layout "sessao"

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to login_path, notice: "Cadastro realizado com sucesso. Faça login para continuar."
    else
      flash.now[:alert] = "Não foi possível realizar cadastro"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [ :nome, :matricula, :password, :password_confirmation ])
  end
end
