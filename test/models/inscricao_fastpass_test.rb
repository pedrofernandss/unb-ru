require "test_helper"

# Turno e janelas são criados aqui, e não em fixtures: o banco de teste também é
# usado pelo Cucumber (ver inscricoes_fastpass_controller_test.rb).
class InscricaoFastpassTest < ActiveSupport::TestCase
  setup do
    @aluno = users(:genaina)
    almoco = TipoRefeicao.create!(nome: "Almoço", hora_inicio: "11:00", hora_fim: "14:00")
    @janela = almoco.time_frames.create!(inicio: "12:00", fim: "12:15")
  end

  test "o banco barra a mesma janela duas vezes no dia mesmo sem a validação" do
    InscricaoFastpass.create!(aluno: @aluno, time_frame: @janela, data: Date.current)
    repetida = InscricaoFastpass.new(aluno: @aluno, time_frame: @janela, data: Date.current)

    assert_raises(ActiveRecord::RecordNotUnique) { repetida.save(validate: false) }
  end

  test "a mesma janela em outro dia é permitida" do
    InscricaoFastpass.create!(aluno: @aluno, time_frame: @janela, data: Date.yesterday)

    assert InscricaoFastpass.new(aluno: @aluno, time_frame: @janela, data: Date.current).save
  end
end
