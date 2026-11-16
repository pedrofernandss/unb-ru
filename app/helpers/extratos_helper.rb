module ExtratosHelper
  # "-R$ 4,50" para débitos e "+R$ 45,00" para recargas.
  def moeda_assinada(valor)
    valor.positive? ? "+#{number_to_currency(valor)}" : number_to_currency(valor)
  end

  # "Hoje", "Ontem" ou o dia da semana.
  def dia_relativo(momento)
    data = momento.to_date

    case data
    when Date.current then "Hoje"
    when Date.yesterday then "Ontem"
    else l(data, format: "%A").capitalize
    end
  end

  def etiqueta_do_tipo(tipo)
    case tipo.to_s.downcase
    when /almoço/ then "etiqueta--almoco"
    when /jantar/ then "etiqueta--jantar"
    when /café/ then "etiqueta--cafe"
    when /recarga/ then "etiqueta--recarga"
    else "etiqueta--neutra"
    end
  end
end
