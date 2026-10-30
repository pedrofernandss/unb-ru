ActiveRecord::Schema[8.1].define(version: 2026_10_30_100011) do
  create_table "campi", force: :cascade do |t|
    t.integer "universidade_id", null: false
    t.string "nome", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["universidade_id", "nome"], name: "index_campi_on_universidade_id_and_nome", unique: true
    t.index ["universidade_id"], name: "index_campi_on_universidade_id"
  end

  create_table "cartoes", force: :cascade do |t|
    t.integer "aluno_id", null: false
    t.string "numero", null: false
    t.string "bandeira", null: false
    t.string "nome", null: false
    t.decimal "saldo", precision: 10, scale: 2, default: "0.0", null: false
    t.date "validade", null: false
    t.string "codigo_verificacao", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aluno_id", "numero"], name: "index_cartoes_on_aluno_id_and_numero", unique: true
    t.index ["aluno_id"], name: "index_cartoes_on_aluno_id"
  end

  create_table "catracas", force: :cascade do |t|
    t.integer "restaurante_id", null: false
    t.integer "funcionario_id"
    t.integer "numero", null: false
    t.integer "piso", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["funcionario_id"], name: "index_catracas_on_funcionario_id", unique: true
    t.index ["restaurante_id", "numero"], name: "index_catracas_on_restaurante_id_and_numero", unique: true
    t.index ["restaurante_id"], name: "index_catracas_on_restaurante_id"
  end

  create_table "historicos_catraca", force: :cascade do |t|
    t.integer "catraca_id", null: false
    t.integer "aluno_id", null: false
    t.datetime "data_hora", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aluno_id", "data_hora"], name: "index_historicos_catraca_on_aluno_id_and_data_hora"
    t.index ["aluno_id"], name: "index_historicos_catraca_on_aluno_id"
    t.index ["catraca_id", "data_hora"], name: "index_historicos_catraca_on_catraca_id_and_data_hora"
    t.index ["catraca_id"], name: "index_historicos_catraca_on_catraca_id"
  end

  create_table "inscricoes_fastpass", force: :cascade do |t|
    t.integer "aluno_id", null: false
    t.integer "restaurante_id", null: false
    t.integer "refeicao_id", null: false
    t.date "data", null: false
    t.time "hora_chegada"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aluno_id", "refeicao_id"], name: "index_inscricoes_fastpass_on_aluno_id_and_refeicao_id", unique: true
    t.index ["aluno_id"], name: "index_inscricoes_fastpass_on_aluno_id"
    t.index ["refeicao_id"], name: "index_inscricoes_fastpass_on_refeicao_id"
    t.index ["restaurante_id"], name: "index_inscricoes_fastpass_on_restaurante_id"
  end

  create_table "refeicoes", force: :cascade do |t|
    t.integer "restaurante_id", null: false
    t.integer "tipo_refeicao_id", null: false
    t.date "data", null: false
    t.text "opcao_normal"
    t.text "opcao_ovolactovegetariana"
    t.text "opcao_vegetariana_estrita"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["restaurante_id", "tipo_refeicao_id", "data"], name: "idx_on_restaurante_id_tipo_refeicao_id_data_f179edd038", unique: true
    t.index ["restaurante_id"], name: "index_refeicoes_on_restaurante_id"
    t.index ["tipo_refeicao_id"], name: "index_refeicoes_on_tipo_refeicao_id"
  end

  create_table "restaurantes", force: :cascade do |t|
    t.integer "campus_id", null: false
    t.string "nome", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campus_id"], name: "index_restaurantes_on_campus_id", unique: true
  end

  create_table "tipos_refeicao", force: :cascade do |t|
    t.string "nome", null: false
    t.time "hora_inicio", null: false
    t.time "hora_fim", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_tipos_refeicao_on_nome", unique: true
  end

  create_table "transacoes", force: :cascade do |t|
    t.integer "aluno_id", null: false
    t.integer "restaurante_id"
    t.integer "refeicao_id"
    t.datetime "data_hora", null: false
    t.string "tipo", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["aluno_id", "data_hora"], name: "index_transacoes_on_aluno_id_and_data_hora"
    t.index ["aluno_id"], name: "index_transacoes_on_aluno_id"
    t.index ["refeicao_id"], name: "index_transacoes_on_refeicao_id"
    t.index ["restaurante_id"], name: "index_transacoes_on_restaurante_id"
  end

  create_table "universidades", force: :cascade do |t|
    t.string "nome", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_universidades_on_nome", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "nome", null: false
    t.string "matricula", null: false
    t.string "password_digest", null: false
    t.string "perfil", default: "aluno", null: false
    t.decimal "saldo", precision: 10, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["matricula"], name: "index_users_on_matricula", unique: true
    t.index ["perfil"], name: "index_users_on_perfil"
  end

  add_foreign_key "campi", "universidades"
  add_foreign_key "cartoes", "users", column: "aluno_id"
  add_foreign_key "catracas", "restaurantes"
  add_foreign_key "catracas", "users", column: "funcionario_id"
  add_foreign_key "historicos_catraca", "catracas"
  add_foreign_key "historicos_catraca", "users", column: "aluno_id"
  add_foreign_key "inscricoes_fastpass", "refeicoes"
  add_foreign_key "inscricoes_fastpass", "restaurantes"
  add_foreign_key "inscricoes_fastpass", "users", column: "aluno_id"
  add_foreign_key "refeicoes", "restaurantes"
  add_foreign_key "refeicoes", "tipos_refeicao", column: "tipo_refeicao_id"
  add_foreign_key "restaurantes", "campi"
  add_foreign_key "transacoes", "refeicoes"
  add_foreign_key "transacoes", "restaurantes"
  add_foreign_key "transacoes", "users", column: "aluno_id"
end
