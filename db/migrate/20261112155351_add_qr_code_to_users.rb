class AddQrCodeToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :qr_code, :string
    add_index :users, :qr_code, unique: true
  end
end
