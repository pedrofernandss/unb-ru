# Be sure to restart your server when you modify this file.

# Plurais em português usados pelos models do domínio (nomes sem acento).
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular "campus", "campi"
  inflect.irregular "cartao", "cartoes"
  inflect.irregular "refeicao", "refeicoes"
  inflect.irregular "transacao", "transacoes"
  inflect.irregular "inscricao", "inscricoes"
  inflect.irregular "perfil", "perfis"
end
