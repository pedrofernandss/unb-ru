module TurnosHelper
  # "11:15 - 14:15": formato usado para turnos e time-frames.
  def faixa_de_horario(inicio, fim)
    "#{inicio.strftime('%H:%M')} - #{fim.strftime('%H:%M')}"
  end

  # Mudar o horário apaga as janelas do turno (TipoRefeicao#descartar_time_frames).
  # Retorna nil quando o turno ainda não tem janelas e não há o que perder.
  def aviso_de_descarte(turno)
    janelas = turno.time_frames.size
    return if janelas.zero?

    "Mudar o horário apaga #{pluralize(janelas, 'janela', plural: 'janelas')} do FastPass deste turno. " \
      "Depois será preciso gerar as janelas de novo."
  end
end
