# Método de acesso/pagamento (QR Code App, PIX, Cartão) e a catraca em que a
# refeição foi consumida, exibidos no extrato do estudante.
class AddMetodoAndCatracaToTransacoes < ActiveRecord::Migration[8.1]
  def change
    add_column :transacoes, :metodo, :string
    add_reference :transacoes, :catraca, null: true, foreign_key: true
  end
end
