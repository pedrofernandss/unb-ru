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
      usuario_id, chave = verificador.verified(@chave, purpose: :recarga)
      return head :unprocessable_entity unless usuario_id == current_user.id && chave.present?

      @recarga = current_user.recargas.find_by(chave: chave)
      unless @recarga
        @recarga = current_user.recargas.build(chave: chave,
          quantidade: params[:outra_quantidade].presence || params[:quantidade], metodo: params[:metodo])
        return render :new, status: :unprocessable_entity unless @recarga.save
      end
      redirect_to recarga_path(@recarga), status: :see_other
    rescue ActiveRecord::RecordNotUnique
      redirect_to recarga_path(current_user.recargas.find_by!(chave: chave)), status: :see_other
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

    # O pacote é cobrado pela tarifa de referência; a lista de turnos deixa
    # visível que cada refeição tem seu próprio preço na catraca.
    def carregar_tarifas
      @turnos = TipoRefeicao.order(:hora_inicio)
      @tarifa_referencia = TarifaRefeicao.referencia
    end

    def exigir_aluno
      head :forbidden unless current_user.aluno?
    end
  end
end
