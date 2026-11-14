class AddConfiguracaoTimeFramesToTiposRefeicao < ActiveRecord::Migration[8.1]
  def change
    add_column :tipos_refeicao, :granularidade_minutos, :integer
    add_column :tipos_refeicao, :tolerancia_minutos, :integer
  end
end
