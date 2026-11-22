module Estudante
  class RecargasController < BaseController
    before_action :exigir_aluno
    before_action :carregar_tarifas, only: %i[new create]

    def new
      @recarga = Recarga.new(quantidade: 5, metodo: "PIX")
      @chave = verificador.generate([ current_user.id, SecureRandom.uuid ], purpose: :recarga)
    end

    def create
      @chave = params[:chave]
      chave = chave_verificada
      return head :unprocessable_entity unless chave

      @recarga = recarga_da_chave(chave)
      return render :new, status: :unprocessable_entity unless @recarga.persisted?

      redirect_to recarga_path(@recarga), status: :see_other
    end

    def show
      @recarga = current_user.recargas.find(params[:id])
    end

    def confirmar
      @recarga = current_user.recargas.find(params[:id])
      @recarga.confirmar!
      mensagem = if @recarga.aprovada?
        { notice: "Recarga realizada com sucesso" }
      elsif @recarga.recusada?
        { alert: "Não foi possível concluir o pagamento" }
      else
        { alert: "Pagamento pendente. Aguarde a confirmação do provedor." }
      end
      redirect_to recarga_path(@recarga), status: :see_other, **mensagem
    end

    private

    def verificador = Rails.application.message_verifier(:recarga)

    # A chave assinada em #new só vale para o aluno que abriu o formulário.
    def chave_verificada
      usuario_id, chave = verificador.verified(@chave, purpose: :recarga)
      chave if usuario_id == current_user.id && chave.present?
    end

    # Reenviar o mesmo formulário devolve a recarga já criada, sem abrir outra.
    def recarga_da_chave(chave)
      current_user.recargas.find_by(chave: chave) || nova_recarga(chave)
    end

    def nova_recarga(chave)
      current_user.recargas.create(chave: chave, quantidade: quantidade_informada, metodo: params[:metodo])
    rescue ActiveRecord::RecordNotUnique
      # Envio duplo simultâneo: a outra requisição gravou a mesma chave primeiro.
      current_user.recargas.find_by!(chave: chave)
    end

    def quantidade_informada = params[:outra_quantidade].presence || params[:quantidade]

    # O pacote é cobrado pela tarifa de referência; a lista de turnos deixa
    # visível que cada refeição tem seu próprio preço na catraca.
    def carregar_tarifas
      @turnos = TipoRefeicao.em_ordem
      @tarifa_referencia = TarifaRefeicao.referencia
    end

    def exigir_aluno
      head :forbidden unless current_user.aluno?
    end
  end
end
