# Sprint 2 — issues de Hendrick

Responsável: @Hendrickhmq. Implementação e validação locais em 6 e 7 de novembro de 2026, com assistência do Codex. Revisão humana e publicação pendentes.

## Estado conferido

- Repositório: https://github.com/pedrofernandss/unb-ru
- `origin/sprint-02`: `6acae72fdbb5a3716b723ee411c45de539f029c7`, confirmado novamente por fetch em 7/11.
- PR #18 integrado à Sprint 1; cenários presentes na Sprint 2.
- PR #27: `932e87e4d51f309514fbbf18ef14094664e5f797`; PR #28: `87843734258f364e83b389fbc4b99dc0c0937a80`. Dependências integradas somente no Git local para validar #15.
- Nenhuma implementação publicada de terminal comum/histórico de Davi ou administração/PDF global de Lucas foi encontrada nas referências disponíveis. As falhas desses BDD foram preservadas e registradas.
- Nenhum push, PR, merge remoto, alteração de issue, kanban ou Wiki foi realizado.

## Plano executado e branches

Ordem: RSpec → #11 → #2 → #5 → dependências do Arthur → #15 → regressão e revisão visual.

| Branch local | Conteúdo e dependências |
| --- | --- |
| `hendrick/sprint-02-rspec` | Configuração mínima e spec de autenticação; mantém Minitest. |
| `hendrick/issue-11-pdf` | Inclui a configuração RSpec e a exportação. Base funcional: `sprint-02`. |
| `hendrick/issue-2-recarga` | Inclui PDF; comparar inicialmente com a branch de PDF. |
| `hendrick/issue-5-ponto` | Inclui PDF/recarga; comparar inicialmente com a branch de recarga. |
| `hendrick/issue-15-fastpass` | Integra as anteriores e os commits dos PRs #27/#28. Branch principal deste trabalho local. |

As correções do adaptador foram aplicadas também às branches de recarga/ponto. As branches formam uma sequência de revisão; não são quatro PRs independentes contra a mesma base. Antes de publicar, atualizar as bases e conferir os diffs. O setup RSpec já acompanha o PDF; não é necessário publicar um PR adicional de setup se ele entrar junto com #11.

## Implementação por issue

### #11 — exportação PDF

`Estudante::ExtratosController#exportar` e `/extrato/exportar` usam `Extrato.new(current_user, filtros)`. O botão GET transporta `Extrato#parametros`; a consulta usa `filtradas`, sem limite/página. `ExtratoPdf` usa Prawn, nome `extrato-refeicoes.pdf`, cabeçalho exigido, acentos portugueses, ordenação e numeração de páginas. Não exporta os indicadores do período como totais das linhas. Sem registros, redireciona preservando filtros e exibe a mensagem do aceite, sem PDF.

Reutilizados: controller, consulta, filtros, layout, botão/ícone e `Transacao` do Pedro. Os steps de `Lancamento` foram adaptados para `Transacao`, usando `restaurante_de_teste`. `pdf-reader` lê o conteúdo efetivo nos testes. Não havia solução de PDF global publicada de Lucas para reaproveitar; Prawn segue o spike do grupo.

### #2 — recarga

Pacotes 2/5/10/20 e quantidade personalizada inteira 1–50, PIX/cartão, revisão do pagamento e cálculo no servidor por `TarifaRefeicao.valor` (R$ 4,50). `Recarga` persiste tentativa pendente e chave única; só uma aprovação gera saldo e `Transacao` positiva, na mesma transação do banco. A confirmação repetida reaproveita o estado. Recusa preserva saldo e não cria crédito. A chave do formulário é assinada e vinculada ao usuário; a consulta/confirmacão é limitada às recargas do usuário autenticado.

O botão Confirmar cria a tentativa e mostra o resumo; Concluir pagamento consulta o adaptador. Nos BDD, o fake escolhe o resultado e o teste conclui pelo HTTP, verificando a resposta atualizada. Não há dados reais de cartão nem gateway real. O simulador aprova apenas em desenvolvimento/teste. Produção permanece pendente até configurar um provedor. O provedor futuro deve honrar a chave de idempotência, inclusive após falha/rollback local.

Reutilizados: `User.saldo`, `Transacao`, autenticação, layout e componentes existentes. `Cartao.saldo` não participa da carteira.

### #5 — configuração de ponto

Área `Operador`, protegida por perfil funcionário, com unidades dinâmicas e catracas agrupadas por piso. Valida seleção, pertencimento e `Catraca#online?`. `numero` deriva o rótulo Catraca 04. O vínculo operacional é exclusivamente `session[:catraca_em_operacao_id]`, limpo pelo login/logout e revalidado em terminal/histórico. `funcionario_id` conserva o significado cadastral; não é usado como sessão ativa. Sessões do mesmo funcionário permanecem independentes. Tentativa inválida limpa o vínculo desta sessão.

Adicionada a coluna `online`, com padrão false. Não há monitoramento real de equipamento: Lucas (#8) deve preencher esse mesmo atributo ou alinhar a fonte na integração. Catracas existentes ficam offline até confirmação de disponibilidade. A preparação visual marcou somente a Catraca 04 do banco descartável de desenvolvimento como online; isso não foi codificado nos seeds do grupo.

Terminal/histórico consomem o mesmo contexto e limitam os registros à catraca escolhida. O histórico entregue é uma base de integração da #5/#15, não a implementação completa da #7 de Davi.

### #15 — FastPass rigoroso

`RegraFastpass` usa `InscricaoFastpass.contemplado`, data da leitura, turno, `TimeFrame` e contexto da catraca. Restrições opcionais de restaurante/refeição são respeitadas. Ausência de janela/inscrição é controlada. O relógio vem do servidor, no fuso Brasília; parâmetros de horário enviados pelo cliente não comandam a validação.

Decisão confirmada pelo usuário: início e fim inclusivos. Para 12:15–12:30, 12:30:00 permite e 12:30:01 bloqueia, independentemente das tolerâncias de 3/5 minutos de outras telas. Saldo insuficiente bloqueia sem débito. Não foi criado `SorteioFastpass` nem limite de uma refeição por dia.

`ValidacaoDeAcesso` centraliza modo comum e FastPass: decisão, débito de `User.saldo`, `Transacao`, `HistoricoCatraca` e evento `ProcessamentoAcesso` com chave única. A resposta HTTP exibe a decisão atualizada. Chave repetida não repete débito, histórico ou comando; trocar matrícula/modo/catraca na mesma chave é recusado. Falha de gravação desfaz toda a operação financeira e não envia comando.

O comando é entregue após persistir a decisão, com registro de entrega e possibilidade de repetir apenas a entrega pendente. O adaptador físico futuro precisa deduplicar a chave do evento. Enquanto a entrega não é confirmada, a tela exibe bloqueio e comando pendente. Há simulador local; sem dispositivo configurado em produção, o acesso é recusado sem débito. A conexão com hardware e a rotina operacional para entregas pendentes precisam ser acertadas com Davi antes de uso real.

## Resultados reais

| Verificação | Resultado |
| --- | --- |
| BDD das quatro issues | 10 cenários / 82 passos aprovados |
| BDD afetados: quatro issues + cadastro/login/extrato + FastPass/turnos do Arthur | 28 cenários / 232 passos aprovados |
| RSpec integrado final | 47 exemplos, 0 falhas |
| Minitest integrado final | 35 testes, 175 assertions, 0 falhas/erros |
| Zeitwerk | Carregamento completo aprovado |
| RuboCop dos arquivos Ruby alterados, excluindo schema gerado | 35 arquivos, nenhuma ocorrência na execução registrada |
| BDD completo | 60 cenários: 28 aprovados, 28 falhos, 4 ambíguos; 2 passos indefinidos |

Os 32 cenários sem aprovação ficam em cardápio, notificação FastPass, relatório global, administração de restaurantes/catracas, histórico local e validação comum. Causas observadas incluem `Meal` inexistente, `numero_de_pisos` inexistente, steps ambíguos e texto de cardápio ainda em construção. Não foram alterados testes dessas funcionalidades para fabricar aprovação. O resultado global não deve ser anunciado como suíte completamente verde.

RuboCop: a execução inicial incluindo `db/schema.rb` apontou 84 ocorrências, predominantemente espaçamento do schema gerado. Foram corrigidos somente espaçamentos de três linhas dos specs novos; o schema não recebeu formatação ampla. CI completo, `test:system` e auditoria de dependências não foram certificados como aprovados.

As migrations de recarga, disponibilidade, processamento de acesso e as dependências #27/#28 foram executadas em banco de teste. RSpec cobre PDF real com 65 registros e múltiplas páginas, isolamento/filtros, limites de quantidade, PIX/cartão aprovados, recusa, rollback, confirmação repetida, autorização, duas sessões, troca/logout, datas erradas, contemplação ausente, limites exatos de horário e repetição de evento.

## Revisão visual e divergências

Foram abertos os quatro frames informados no navegador. O conector Figma recusou acesso ao contexto de design por exigir acesso de editor; por isso não há certificação de reprodução exata de medidas/assets. A implementação reutiliza tokens, logo, HAML e componentes locais. No navegador local foram conferidos recarga, resumo/aprovação/saldo atualizado, extrato, exportação vazia, ponto com múltiplas unidades, erro offline, terminal vazio, bloqueio sem contemplação e liberação FastPass com débito e relógio real. Um PDF real de 65 registros foi renderizado em seis páginas; primeira e última páginas foram inspecionadas, com acentos e paginação legíveis.

Divergências deliberadas: datas e textos dos BDD existentes foram mantidos; os métodos de pagamento são radios; o resumo final fica em uma etapa antes da cobrança; não há QR bancário decorativo nem botões de simulação de horário de produção. A interface do operador usa dados reais de múltiplos restaurantes, sem fixar a unidade do Figma. Esses pontos devem ser revisados pelo grupo, sem confundir exemplos do protótipo com regras fixas.

## Pendências e decisões para integração

1. Arthur: aprovar/integrar #27/#28 antes de integrar #15 à base definitiva. A migration de #28 adiciona `time_frame_id` obrigatório sem backfill: conferir dados existentes antes de aplicá-la fora dos bancos descartáveis.
2. Davi (#6/#7): integrar a leitura/terminal e histórico ao serviço comum e ao contexto por sessão; manter um único débito e um único adaptador de comando. Os steps antigos de validação comum ainda usam R$ 5,00, enquanto os aceites #2/#15 e os exemplos do extrato usam R$ 4,50. Esta entrega usa R$ 4,50 centralizado; alinhar o contrato de #6 com Davi antes da aceitação global. Os steps de #6 não foram alterados.
3. Lucas (#8): alinhar a disponibilidade no atributo `online`, evitando outra fonte paralela; revisar a migration quando a administração for integrada. Lucas (#12): considerar reutilizar Prawn/estrutura do PDF para relatório global.
4. Grupo/PO: propagar a regra confirmada de janela exata e fim inclusivo para os textos divergentes das telas de turnos/sorteio. Não há decisão bloqueante restante para os dez BDD solicitados.
5. Revisão visual exata de assets/medidas depende de contexto Figma acessível; a revisão realizada foi visual e funcional, sem alegação de equivalência pixel a pixel.
6. Confirmar data, branch de release e destino da entrega acadêmica. O PDF de instruções menciona 09/06/2026 e CAMAAR/master, incompatíveis com o repositório/data atuais. Nenhuma publicação deve ser derivada desses dados automaticamente.

## Como revisar e integrar

1. Conferir `git status`, branches e SHAs. Revisar primeiro #11, depois #2, #5 e #15. Os arquivos por commit estão em `arquivos-alterados.txt`.
2. Usar as descrições em `prs.md` e o texto em `wiki.md`. São rascunhos locais; publicação depende de instrução explícita.
3. Executar os comandos de `validacao.md` e comparar os logs. Revisar especialmente migrations, filtros PDF, chaves de idempotência e pontos compartilhados com Davi/Lucas.
4. Atualizar as branches locais com a base aprovada do grupo e resolver somente conflitos necessários. Se `schema.rb` conflitar, aplicar todas as migrations em banco descartável e regenerar; não escolher um lado apagando entidades.
5. Após revisão humana, obter autorização para push/PR/merge e para atualizar Wiki/kanban. Criar a release final somente com destino e prazo confirmados.
