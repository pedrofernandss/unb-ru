class AddItensExtrasToRefeicoes < ActiveRecord::Migration[8.1]
  def change
    add_column :refeicoes, :itens_extras, :json
  end
end
