# Helpers compartilhados pelos step definitions.

# Converte "R$ 40,50" em 40.50 para comparar com o valor numérico do banco.
def valor_em_reais(texto)
  texto.gsub(/[^\d,-]/, "").tr(",", ".").to_d
end
