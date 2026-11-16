class AddOnlineToCatracas < ActiveRecord::Migration[8.1]
  def change
    add_column :catracas, :online, :boolean, default: false, null: false
  end
end
