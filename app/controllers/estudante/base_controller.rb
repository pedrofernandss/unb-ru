module Estudante
  # Controllers do Portal do Estudante: exigem login e usam o layout "estudante".
  class BaseController < ApplicationController
    layout "estudante"

    private

    # Funcionário também usa o portal (home e extrato), mas o FastPass é só para alunos.
    def exigir_aluno
      return if current_user.aluno?

      redirect_to home_path, alert: "O FastPass é exclusivo para alunos"
    end
  end
end
