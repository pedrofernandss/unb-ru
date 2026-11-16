class Refeicao < ApplicationRecord
  belongs_to :restaurante
  belongs_to :tipo_refeicao

  has_many :inscricoes_fastpass, class_name: "InscricaoFastpass", dependent: :destroy
  has_many :transacoes, dependent: :nullify

  validates :data, presence: true
  validates :tipo_refeicao_id, uniqueness: { scope: [ :restaurante_id, :data ] }

  ROTULOS_CATEGORIAS = {
    "bebidas" => "Bebidas",
    "panificacao" => "Panificação",
    "opcao_extra" => "Opção extra",
    "gordura" => "Gordura",
    "fruta" => "Fruta",
    "salada" => "Salada",
    "molho_para_salada" => "Molho para salada",
    "guarnicao" => "Guarnição",
    "sopa" => "Sopa",
    "torrada" => "Torrada",
    "acompanhamentos" => "Acompanhamentos",
    "sobremesa" => "Sobremesa",
    "bebida" => "Bebida"
  }.freeze

  def opcoes_estruturadas
    extras = categorias_detalhadas
    rotulo_principal = tipo_refeicao&.nome == "Café da manhã" ? "Complemento" : "Prato principal"

    [
      {
        titulo: "Opção padrão",
        linhas: [ [ rotulo_principal, normalizar_texto(opcao_normal.presence || "Não informado") ] ] + extras
      },
      {
        titulo: "Opção ovolactovegetariana",
        linhas: [ [ rotulo_principal, normalizar_texto(opcao_ovolactovegetariana.presence || "Não informado") ] ] + extras
      },
      {
        titulo: "Opção vegetariana estrita",
        linhas: [ [ rotulo_principal, normalizar_texto(opcao_vegetariana_estrita.presence || "Não informado") ] ] + extras
      }
    ]
  end

  def categorias_detalhadas
    dados = (itens_extras.presence || {}).dup
    saladas = [ dados.delete("salada_1"), dados.delete("salada_2") ].compact_blank
    dados["salada"] = saladas if saladas.any?

    ROTULOS_CATEGORIAS.filter_map do |chave, rotulo|
      valor = dados[chave]
      next if valor.blank?

      texto = valor.is_a?(Array) ? valor.join(" · ") : valor.to_s
      [ rotulo, normalizar_texto(texto) ]
    end
  end

  private

  def normalizar_texto(texto)
    texto.to_s.gsub(/\bOU\b/, "ou")
  end
end
