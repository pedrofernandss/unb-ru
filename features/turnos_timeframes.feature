# language: pt
 Funcionalidade: Gestão de Turnos e Time-Frames
  Como administrador
  Eu quero definir os horários dos turnos e dividi-los em time-frames configuráveis
  Para organizar a distribuição do FastPass

  Contexto:
    Dado que eu estou logado como um administrador
    E existem os seguintes turnos cadastrados:
      | turno         | inicio | fim   |
      | Café da Manhã | 07:00  | 09:00 |
      | Almoço        | 11:15  | 14:15 |
      | Jantar        | 17:30  | 19:30 |

  Cenário: Editar o horário de um turno
    Dado que eu acesso a página de turnos e time-frames
    Quando eu clico no botão "Editar Horários do Almoço"
    E eu preencho o campo "Início" com "11:00"
    E eu preencho o campo "Fim" com "14:00"
    E eu clico no botão "Salvar"
    Então eu devo ver a mensagem "Turno atualizado com sucesso"
    E o turno "Almoço" deve exibir o horário "11:00 - 14:00"

  Esquema do Cenário: Editar turno com horário inválido
    Dado que eu acesso a página de turnos e time-frames
    Quando eu clico no botão "Editar Horários do Almoço"
    E eu preencho o campo "Início" com "<inicio>"
    E eu preencho o campo "Fim" com "<fim>"
    E eu clico no botão "Salvar"
    Então eu devo ver a mensagem "<mensagem>"
    E o turno "Almoço" deve exibir o horário "11:15 - 14:15"

    Exemplos:
      | inicio | fim   | mensagem                                        |
      | 14:00  | 11:00 | O horário final deve ser posterior ao inicial   |
      | 25:00  | 14:15 | Horário inválido                                |
      | 11:15  | 18:00 | O horário do Almoço se sobrepõe ao turno Jantar |

  Cenário: Dividir um turno em time-frames de FastPass
    Dado que eu acesso a página de turnos e time-frames
    Quando eu seleciono "Almoço" no campo "Turno de Referência"
    E eu preencho o campo "Granularidade da Janela" com "15"
    E eu preencho o campo "Tolerância de Atraso" com "3"
    E eu clico no botão "Salvar Configuração"
    Então eu devo ver a mensagem "Time-frames gerados com sucesso"
    E o turno "Almoço" deve possuir 12 time-frames
    E o primeiro time-frame do turno "Almoço" deve ser "11:15 - 11:30"
    E o último time-frame do turno "Almoço" deve ser "14:00 - 14:15"

  Esquema do Cenário: Configurar time-frames com granularidade inválida
    Dado que eu acesso a página de turnos e time-frames
    Quando eu seleciono "Almoço" no campo "Turno de Referência"
    E eu preencho o campo "Granularidade da Janela" com "<granularidade>"
    E eu preencho o campo "Tolerância de Atraso" com "3"
    E eu clico no botão "Salvar Configuração"
    Então eu devo ver a mensagem "<mensagem>"
    E o turno "Almoço" deve possuir 0 time-frames

    Exemplos:
      | granularidade | mensagem                                                   |
      | 0             | A granularidade deve ser maior que 0                       |
      | 7             | A granularidade deve dividir a duração do turno (180 min) |
      | quinze        | A granularidade deve ser um número                         |

  Cenário: Estudante tenta acessar a gestão de turnos
    Dado que eu estou logado como um estudante
    Quando eu tento acessar a página de turnos e time-frames
    Então eu devo ser redirecionado para a página "/home"
    E eu devo ver a mensagem "Acesso restrito a administradores"
