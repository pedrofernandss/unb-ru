module TurnosHelper
  # "11:15 - 14:15": formato usado para turnos e time-frames.
  def faixa_de_horario(inicio, fim)
    "#{inicio.strftime('%H:%M')} - #{fim.strftime('%H:%M')}"
  end
end
