# Atributos da requisição atual (usuário autenticado).
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end
