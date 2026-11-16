module FastpassHelper
  # Mensagem do painel de resultado (US14). Inscrição ainda "inscrito" depois do
  # horário de divulgação quer dizer que o sorteio ainda não rodou. Um status novo
  # sem mensagem levanta erro, em vez de aparecer para o aluno como "processando".
  def mensagem_do_resultado(inscricao)
    if inscricao.contemplado? then "Você ganhou o FastPass!"
    elsif inscricao.nao_contemplado? then "Você não ganhou o FastPass. Boa sorte na próxima vez."
    elsif inscricao.inscrito? then "O resultado do sorteio ainda está sendo processado. Volte em instantes."
    else raise ArgumentError, "status sem mensagem de resultado: #{inscricao.status}"
    end
  end
end
