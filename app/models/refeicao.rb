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

  # Painéis do cardápio, na ordem exibida na tela inicial.
  OPCOES = {
    "Opção padrão" => :opcao_normal,
    "Opção ovolactovegetariana" => :opcao_ovolactovegetariana,
    "Opção vegetariana estrita" => :opcao_vegetariana_estrita
  }.freeze

  # Um painel por opção: o prato da opção seguido dos itens comuns a todas.
  def opcoes_estruturadas
    extras = categorias_detalhadas
    OPCOES.map do |titulo, coluna|
      { titulo: titulo, linhas: [ [ rotulo_principal, prato(coluna) ] ] + extras }
    end
  end

  # [rótulo, texto] de cada categoria preenchida, na ordem de ROTULOS_CATEGORIAS.
  def categorias_detalhadas
    dados = itens_agrupados
    ROTULOS_CATEGORIAS.filter_map do |chave, rotulo|
      valor = dados[chave]
      [ rotulo, formatar_item(valor) ] if valor.present?
    end
  end

  private

  # O café da manhã não tem prato principal, e sim complemento.
  def rotulo_principal = tipo_refeicao&.nome == "Café da manhã" ? "Complemento" : "Prato principal"

  def prato(coluna) = normalizar_texto(public_send(coluna).presence || "Não informado")

  # salada_1 e salada_2 aparecem juntas na categoria "salada".
  def itens_agrupados
    dados = (itens_extras.presence || {}).dup
    saladas = [ dados.delete("salada_1"), dados.delete("salada_2") ].compact_blank
    dados["salada"] = saladas if saladas.any?
    dados
  end

  def formatar_item(valor) = normalizar_texto(valor.is_a?(Array) ? valor.join(" · ") : valor.to_s)

  def normalizar_texto(texto)
    texto.to_s.gsub(/\bOU\b/, "ou")
  end
end
