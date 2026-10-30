# Helpers compartilhados pelos step definitions.

# Converte "R$ 40,50" em 40.50 para comparar com o valor numérico do banco.
def valor_em_reais(texto)
  texto.gsub(/[^\d,-]/, "").tr(",", ".").to_d
end

# Garante um restaurante com esse nome, criando universidade e campus se preciso.
def restaurante_de_teste(nome)
  Restaurante.find_by(nome: nome) || begin
    universidade = Universidade.find_or_create_by!(nome: "Universidade de Brasília")
    campus = universidade.campi.find_or_create_by!(nome: nome.delete_prefix("RU "))
    campus.restaurante || Restaurante.create!(campus: campus, nome: nome)
  end
end
