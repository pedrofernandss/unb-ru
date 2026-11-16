class CreateTimeFrames < ActiveRecord::Migration[8.1]
  def change
    create_table :time_frames do |t|
      t.references :tipo_refeicao, null: false, foreign_key: { to_table: :tipos_refeicao }
      t.time :inicio, null: false
      t.time :fim, null: false

      t.timestamps
    end

    add_index :time_frames, [ :tipo_refeicao_id, :inicio ], unique: true
  end
end
