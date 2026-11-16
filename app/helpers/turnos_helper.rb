module TurnosHelper
  # "11:15 - 14:15": formato usado para turnos e time-frames.
  def faixa_de_horario(inicio, fim)
    "#{inicio.strftime('%H:%M')} - #{fim.strftime('%H:%M')}"
  end

  # Mudar o horário apaga as janelas do turno (TipoRefeicao#descartar_time_frames)
  # e, em cascata, as inscrições feitas nelas (TimeFrame dependent: :destroy).
  # Retorna nil quando o turno ainda não tem janelas e não há o que perder.
  def aviso_de_descarte(turno)
    janelas = turno.time_frames.size
    return if janelas.zero?

    inscricoes = turno.inscricoes_fastpass.count
    perdas = pluralize(janelas, "janela", plural: "janelas") + " do FastPass deste turno"
    perdas += " e #{pluralize(inscricoes, 'inscrição', plural: 'inscrições')} de alunos nelas" if inscricoes.positive?

    "Mudar o horário apaga #{perdas}. Depois será preciso gerar as janelas de novo."
  end

  # Salvar Configuração com outra granularidade recria as janelas (TipoRefeicao#configurar_time_frames)
  # e apaga as inscrições feitas nelas. O turno é escolhido no próprio formulário, por isso o aviso
  # não traz a contagem de um turno só. Retorna nil enquanto nenhum turno tem janelas.
  def aviso_de_reconfiguracao(turnos)
    return unless turnos.any? { |turno| turno.time_frames.any? }

    "Se a granularidade mudar, as janelas do turno escolhido e as inscrições de alunos nelas serão apagadas, " \
      "e as janelas geradas de novo. Deseja continuar?"
  end
end
