# Fecha os defaults da 20261113014801. "Comum"/"Liberado"/R$ 4,50 fazem um registro
# incompleto parecer legítimo: acesso bloqueado entra no relatório global (#9) como
# refeição servida e soma uma arrecadação que não existiu, sem quebrar nenhum teste.
# Sem default, quem gravar um acesso sem decidir modo, status e tarifa falha na hora.
class RestringeDetalhesHistoricosCatraca < ActiveRecord::Migration[8.1]
  def change
    # O motivo é o que o funcionário na catraca precisa ler: "Bloqueado" sozinho não
    # diz se foi saldo, catraca offline ou leitura fora do turno.
    add_column :historicos_catraca, :motivo, :string

    change_column_default :historicos_catraca, :modo_validacao, from: "Comum", to: nil
    change_column_default :historicos_catraca, :status, from: "Liberado", to: nil
    change_column_default :historicos_catraca, :tarifa, from: BigDecimal("4.50"), to: nil

    change_column_null :historicos_catraca, :modo_validacao, false
    change_column_null :historicos_catraca, :status, false
    change_column_null :historicos_catraca, :tarifa, false
  end
end
