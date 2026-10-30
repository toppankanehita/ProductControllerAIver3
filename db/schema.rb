# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2026_07_27_225828) do

  create_table "add_data", charset: "utf8", force: :cascade do |t|
    t.integer "n01"
    t.integer "n02"
    t.integer "n03"
    t.integer "n04"
    t.integer "n05"
    t.integer "dai"
    t.integer "mentuke"
    t.integer "sp"
    t.string "machine"
    t.integer "press_num"
    t.integer "sales_price"
    t.integer "iroko_num"
    t.integer "out_cost"
    t.integer "assembly"
    t.integer "delivery"
    t.integer "ctp"
    t.integer "kako"
    t.integer "pod"
    t.integer "dtp"
    t.string "parent_code"
    t.decimal "vprice", precision: 10
    t.integer "job_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["job_id"], name: "job_id"
  end

  create_table "add_presses", charset: "utf8mb4", force: :cascade do |t|
    t.integer "position"
    t.integer "press_num"
    t.integer "men"
    t.integer "jisu"
    t.string "machine"
    t.string "han"
    t.string "iro"
    t.integer "dai"
    t.float "kake"
    t.decimal "daitanka", precision: 11, scale: 2, default: "0.0"
    t.decimal "tanka", precision: 11, scale: 2, default: "0.0"
    t.decimal "dai_price", precision: 11, scale: 2, default: "0.0"
    t.integer "job_id"
    t.integer "zara"
    t.integer "toku"
    t.integer "kin"
    t.integer "upo"
    t.integer "iroa"
    t.integer "irob"
    t.float "kake2"
    t.integer "page"
    t.integer "sasi", default: 1
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "add_values", charset: "utf8", force: :cascade do |t|
    t.string "den_code"
    t.string "post_press"
    t.string "paper_name"
    t.string "paper_route"
    t.decimal "ren", precision: 10, scale: 1
    t.integer "ita"
    t.integer "before_yobi"
    t.integer "yobi", unsigned: true
    t.decimal "ktanka", precision: 6, scale: 2, default: "0.0"
    t.decimal "diff_before_weight", precision: 6, scale: 2, default: "0.0"
    t.decimal "mtanka", precision: 6, scale: 2, default: "0.0"
    t.decimal "diff_before_price", precision: 11, scale: 2, default: "0.0"
    t.integer "jisu"
    t.integer "press_num", unsigned: true
    t.decimal "weight", precision: 8, scale: 2, default: "0.0"
    t.decimal "paper_price", precision: 11, scale: 2, default: "0.0"
    t.integer "job_id"
    t.integer "special"
    t.datetime "created_at", precision: 6
    t.datetime "updated_at", precision: 6
    t.integer "tori"
    t.integer "position"
    t.string "han"
    t.string "me"
    t.decimal "sale_price", precision: 11, scale: 2, default: "0.0"
    t.string "other"
    t.integer "dai"
    t.integer "upo"
    t.integer "kaleid"
    t.integer "gold"
    t.integer "iroko"
    t.integer "sasi", default: 0
    t.float "men", default: 1.0
    t.index ["den_code"], name: "jden_code"
    t.index ["job_id"], name: "job_id"
  end

  create_table "archives", charset: "utf8mb4", force: :cascade do |t|
    t.string "textInfo02"
    t.string "den_id"
    t.string "textInfo05"
    t.string "textInfo07"
    t.integer "numInfo01", default: 0
    t.integer "numInfo02", default: 0
    t.integer "numInfo03", default: 0
    t.integer "numInfo06"
    t.integer "numInfo07"
    t.integer "numInfo14"
    t.integer "numInfo15"
    t.date "press_date"
    t.date "finish_date"
    t.date "sale_date"
    t.string "press_size"
    t.string "press_siage_size"
    t.string "press_tenkai_size"
    t.string "press_color"
    t.string "press_special"
    t.string "press_upo"
    t.string "press_kaleido"
    t.string "textInfo11"
    t.integer "ita"
    t.string "kako"
    t.string "booklet"
    t.string "paper_route"
    t.string "paper_name"
    t.string "post_press"
    t.integer "press_num", default: 0
    t.integer "paper_jisu", default: 0
    t.integer "paper_yobi", default: 0
    t.integer "paper_split", limit: 3, default: 1
    t.decimal "paper_ren", precision: 6, scale: 2, default: "0.0"
    t.integer "paper_sasi", limit: 3, default: 0
    t.decimal "ktanka", precision: 6, scale: 2, default: "0.0"
    t.decimal "mtanka", precision: 6, scale: 2, default: "0.0"
    t.decimal "paper_weight", precision: 8, scale: 2, default: "0.0"
    t.decimal "sale_paper", precision: 11, scale: 2, default: "0.0"
    t.decimal "sale_press", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost_paper", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost_ctp", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost_press", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost_pod", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost_kako", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost_seisaku", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost_gaicyu", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost_assembly", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost_haiso", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost_keihi", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost_sum", precision: 11, scale: 2, default: "0.0"
    t.decimal "sale_sum", precision: 11, scale: 2, default: "0.0"
    t.decimal "arari", precision: 11, scale: 2, default: "0.0"
    t.string "parent_job"
    t.string "child_job"
    t.string "sales_name"
    t.integer "job_id"
    t.decimal "sale_ctp", precision: 11, scale: 2, default: "0.0"
    t.decimal "sale_pod", precision: 11, scale: 2, default: "0.0"
    t.decimal "sale_kako", precision: 11, scale: 2, default: "0.0"
    t.decimal "sale_seisaku", precision: 11, scale: 2, default: "0.0"
    t.decimal "sale_gaicyu", precision: 11, scale: 2, default: "0.0"
    t.decimal "sale_assembly", precision: 11, scale: 2, default: "0.0"
    t.decimal "sale_haiso", precision: 11, scale: 2, default: "0.0"
    t.float "cal_paper"
    t.float "cal_press"
    t.float "cal_ctp"
    t.float "cal_pod"
    t.float "cal_kako"
    t.float "cal_seisaku"
    t.float "cal_gaicyu"
    t.float "cal_assembly"
    t.float "cal_haiso"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "sale_mitumori", precision: 11, scale: 2, default: "0.0"
    t.decimal "sale_keihi", precision: 11, scale: 2, default: "0.0"
    t.integer "mission_archive_00"
    t.string "mission_archive_01"
    t.string "mission_archive_02"
    t.string "mission_archive_03"
    t.string "mission_archive_04"
    t.string "mission_archive_05"
    t.string "mission_archive_06"
    t.decimal "mission_archive_07", precision: 10
    t.decimal "mission_archive_08", precision: 10
    t.decimal "mission_archive_09", precision: 10
    t.decimal "mission_archive_10", precision: 10
    t.decimal "mission_archive_11", precision: 10
    t.decimal "mission_archive_12", precision: 10
    t.float "mission_archive_13"
    t.decimal "mission_archive_14", precision: 10
    t.decimal "mission_archive_15", precision: 10
    t.float "mission_archive_16"
    t.decimal "mission_archive_17", precision: 10
    t.decimal "mission_archive_18", precision: 10
    t.float "mission_archive_19"
    t.decimal "mission_archive_20", precision: 10
    t.decimal "mission_archive_21", precision: 10
    t.float "mission_archive_22"
    t.decimal "mission_archive_23", precision: 10
    t.float "mission_archive_24"
    t.decimal "mission_archive_25", precision: 10
    t.decimal "mission_archive_26", precision: 10
    t.decimal "mission_archive_27", precision: 10
    t.decimal "mission_archive_28", precision: 10
    t.decimal "mission_archive_29", precision: 10
    t.decimal "mission_archive_30", precision: 10
    t.decimal "mission_archive_31", precision: 10
    t.decimal "mission_archive_32", precision: 10
    t.decimal "mission_archive_33", precision: 10
    t.decimal "mission_archive_34", precision: 10
    t.decimal "mission_archive_35", precision: 10
    t.decimal "mission_archive_36", precision: 10
    t.decimal "mission_archive_37", precision: 10
    t.decimal "mission_archive_38", precision: 10
    t.decimal "mission_archive_39", precision: 10
    t.decimal "mission_archive_40", precision: 10
    t.decimal "mission_archive_41", precision: 10
    t.decimal "mission_archive_42", precision: 10
    t.decimal "mission_archive_43", precision: 10
    t.decimal "mission_archive_44", precision: 10
    t.decimal "mission_archive_45", precision: 10
    t.float "mission_archive_46"
    t.decimal "mission_archive_47", precision: 10
    t.decimal "mission_archive_48", precision: 10
    t.decimal "mission_archive_49", precision: 10
    t.decimal "mission_archive_50", precision: 10
    t.decimal "mission_archive_51", precision: 10
    t.decimal "mission_archive_52", precision: 10
    t.decimal "mission_archive_53", precision: 10
    t.decimal "mission_archive_54", precision: 10
    t.decimal "mission_archive_55", precision: 10
    t.decimal "mission_archive_56", precision: 10
    t.decimal "mission_archive_57", precision: 10
    t.decimal "mission_archive_58", precision: 10
    t.decimal "mission_archive_59", precision: 10
    t.decimal "mission_archive_60", precision: 10
    t.index ["cost_paper"], name: "cal_paper"
    t.index ["den_id"], name: "den_id"
    t.index ["finish_date"], name: "finish"
    t.index ["job_id"], name: "job_id"
    t.index ["press_date"], name: "press"
    t.index ["textInfo05", "textInfo07", "textInfo02"], name: "job3"
    t.index ["textInfo05", "textInfo07"], name: "job"
  end

  create_table "costs", charset: "utf8", force: :cascade do |t|
    t.string "target_month"
    t.decimal "cost01", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost02", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost03", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost04", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost05", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost06", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost07", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost08", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost09", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost10", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost11", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost12", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost13", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost14", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost15", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost16", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost17", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost18", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost19", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost20", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_cost", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_sales", precision: 11, scale: 2, default: "0.0"
    t.decimal "sales_cost", precision: 11, scale: 2, default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "all_paper_web", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_paper_sheet", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_press_web", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_press_sheet", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_roumu_product", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_roumu_create", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_roumu_design", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_assembly", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_outsourcing", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_ctp_plate", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_pod_cost", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost21", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost22", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost23", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost24", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost25", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_ctp_sheet", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_slip_sales", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_out_cost", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_in_cost", precision: 11, scale: 2, default: "0.0"
    t.decimal "all_delivery_cost", precision: 11, scale: 2
    t.decimal "all_web_minus", precision: 10
    t.decimal "all_paper", precision: 10
  end

  create_table "debits", charset: "utf8", force: :cascade do |t|
    t.string "target_month"
    t.string "den_code"
    t.integer "job_id"
    t.string "siwake"
    t.string "name"
    t.decimal "out_cost", precision: 10
    t.decimal "in_cost", precision: 10
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "grid_settings", charset: "utf8mb4", force: :cascade do |t|
    t.integer "canvas_width"
    t.integer "canvas_height"
    t.integer "rect_width"
    t.integer "rect_height"
    t.integer "cols"
    t.integer "rows"
    t.integer "base_horizontal_gap"
    t.integer "base_vertical_gap"
    t.integer "center_horizontal_gap"
    t.integer "center_vertical_gap"
    t.integer "even_position_horizontal_gap"
    t.integer "even_position_vertical_gap"
    t.integer "fixed_padding_bottom"
    t.integer "job_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "mission_archives", charset: "utf8", force: :cascade do |t|
    t.integer "mission_archive_00"
    t.string "mission_archive_01"
    t.string "mission_archive_02"
    t.string "mission_archive_03"
    t.string "mission_archive_04"
    t.string "mission_archive_05"
    t.string "mission_archive_06"
    t.decimal "mission_archive_07", precision: 10
    t.decimal "mission_archive_08", precision: 10
    t.decimal "mission_archive_09", precision: 10
    t.decimal "mission_archive_10", precision: 10
    t.decimal "mission_archive_11", precision: 10
    t.decimal "mission_archive_12", precision: 10
    t.float "mission_archive_13"
    t.decimal "mission_archive_14", precision: 10
    t.decimal "mission_archive_15", precision: 10
    t.float "mission_archive_16"
    t.decimal "mission_archive_17", precision: 10
    t.decimal "mission_archive_18", precision: 10
    t.float "mission_archive_19"
    t.decimal "mission_archive_20", precision: 10
    t.decimal "mission_archive_21", precision: 10
    t.decimal "mission_archive_22", precision: 10, scale: 2
    t.decimal "mission_archive_23", precision: 10
    t.decimal "mission_archive_24", precision: 10, scale: 2
    t.decimal "mission_archive_25", precision: 10
    t.decimal "mission_archive_26", precision: 10
    t.decimal "mission_archive_27", precision: 10
    t.decimal "mission_archive_28", precision: 10
    t.decimal "mission_archive_29", precision: 10
    t.decimal "mission_archive_30", precision: 10
    t.decimal "mission_archive_31", precision: 10
    t.decimal "mission_archive_32", precision: 10
    t.decimal "mission_archive_33", precision: 10
    t.decimal "mission_archive_34", precision: 10
    t.decimal "mission_archive_35", precision: 10
    t.decimal "mission_archive_36", precision: 10
    t.decimal "mission_archive_37", precision: 10
    t.decimal "mission_archive_38", precision: 10
    t.decimal "mission_archive_39", precision: 10
    t.decimal "mission_archive_40", precision: 10
    t.decimal "mission_archive_41", precision: 10
    t.decimal "mission_archive_42", precision: 10
    t.decimal "mission_archive_43", precision: 10
    t.decimal "mission_archive_44", precision: 10
    t.decimal "mission_archive_45", precision: 10
    t.float "mission_archive_46"
    t.string "target_month"
    t.integer "job_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.decimal "mission_archive_47", precision: 10
    t.decimal "mission_archive_48", precision: 10
    t.decimal "mission_archive_49", precision: 10
    t.decimal "mission_archive_50", precision: 10
    t.decimal "mission_archive_51", precision: 10
    t.decimal "mission_archive_52", precision: 10
    t.decimal "mission_archive_53", precision: 10
    t.decimal "mission_archive_54", precision: 10
    t.decimal "mission_archive_55", precision: 10
    t.decimal "mission_archive_56", precision: 10
    t.decimal "mission_archive_57", precision: 10
    t.decimal "mission_archive_58", precision: 10
    t.decimal "mission_archive_59", precision: 10
    t.decimal "mission_archive_60", precision: 10
  end

  create_table "paper_lists", charset: "utf8", force: :cascade do |t|
    t.date "date01"
    t.string "full_name"
    t.string "name"
    t.string "opt1"
    t.string "opt2"
    t.string "han"
    t.string "line"
    t.decimal "ren", precision: 6, scale: 2, default: "0.0"
    t.integer "kiri"
    t.integer "tori", null: false
    t.integer "ita"
    t.decimal "ktanka", precision: 10, scale: 2
    t.decimal "mtanka", precision: 10, scale: 2
    t.decimal "printer_price", precision: 6, scale: 2, default: "0.0"
    t.decimal "unit_price", precision: 6, scale: 2, default: "0.0"
    t.integer "area_size"
    t.integer "paper_type_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "paper_types", charset: "utf8", force: :cascade do |t|
    t.string "category"
    t.string "type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "press_data", charset: "utf8", force: :cascade do |t|
    t.string "den_code"
    t.string "product_name"
    t.string "paper_no"
    t.datetime "start_time"
    t.integer "work_time"
    t.integer "n01"
    t.integer "n02"
    t.string "machine"
    t.integer "job_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sessions", charset: "utf8", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "size_lists", charset: "utf8", force: :cascade do |t|
    t.decimal "weight", precision: 6, scale: 2, default: "0.0"
    t.string "kind"
    t.string "han"
    t.decimal "weight_per_m", precision: 6, scale: 2, default: "0.0"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "tworks", charset: "utf8", force: :cascade do |t|
    t.integer "no"
    t.date "delivery_date"
    t.string "tinfo05"
    t.string "tinfo07"
    t.string "quote_no"
    t.decimal "quantity", precision: 11, scale: 2, default: "0.0"
    t.integer "billing_amount"
    t.decimal "cost1", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost2", precision: 11, scale: 2, default: "0.0"
    t.decimal "cost3", precision: 11, scale: 2, default: "0.0"
    t.decimal "total_cost", precision: 11, scale: 2, default: "0.0"
    t.decimal "profit", precision: 11, scale: 2, default: "0.0"
    t.string "contractor1"
    t.string "contractor2"
    t.string "contractor3"
    t.string "customer_code"
    t.text "remarks"
    t.string "staff"
    t.string "den_code"
    t.decimal "outsourcing_cost", precision: 11, scale: 2, default: "0.0"
    t.decimal "purchase_cost", precision: 11, scale: 2, default: "0.0"
    t.float "work_time"
    t.decimal "work_cost", precision: 11, scale: 2, default: "0.0"
    t.string "target_month"
    t.string "delivery_no"
    t.integer "unit_price"
    t.float "profit_margin"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "work_data", charset: "utf8", force: :cascade do |t|
    t.integer "mission_archive_00"
    t.string "mission_archive_01"
    t.string "mission_archive_02"
    t.string "mission_archive_03"
    t.string "mission_archive_04"
    t.string "mission_archive_05"
    t.string "mission_archive_06"
    t.decimal "mission_archive_07", precision: 10
    t.decimal "mission_archive_08", precision: 10
    t.decimal "mission_archive_09", precision: 10
    t.decimal "mission_archive_10", precision: 10
    t.decimal "mission_archive_11", precision: 10
    t.decimal "mission_archive_12", precision: 10
    t.float "mission_archive_13"
    t.decimal "mission_archive_14", precision: 10
    t.decimal "mission_archive_15", precision: 10
    t.float "mission_archive_16"
    t.decimal "mission_archive_17", precision: 10
    t.decimal "mission_archive_18", precision: 10
    t.float "mission_archive_19"
    t.decimal "mission_archive_20", precision: 10
    t.decimal "mission_archive_21", precision: 10
    t.decimal "mission_archive_22", precision: 10
    t.decimal "mission_archive_23", precision: 10
    t.decimal "mission_archive_24", precision: 10
    t.decimal "mission_archive_25", precision: 10
    t.decimal "mission_archive_26", precision: 10
    t.decimal "mission_archive_27", precision: 10
    t.decimal "mission_archive_28", precision: 10
    t.decimal "mission_archive_29", precision: 10
    t.decimal "mission_archive_30", precision: 10
    t.decimal "mission_archive_31", precision: 10
    t.decimal "mission_archive_32", precision: 10
    t.decimal "mission_archive_33", precision: 10
    t.decimal "mission_archive_34", precision: 10
    t.decimal "mission_archive_35", precision: 10
    t.decimal "mission_archive_36", precision: 10
    t.decimal "mission_archive_37", precision: 10
    t.decimal "mission_archive_38", precision: 10
    t.decimal "mission_archive_39", precision: 10
    t.decimal "mission_archive_40", precision: 10
    t.decimal "mission_archive_41", precision: 10
    t.decimal "mission_archive_42", precision: 10
    t.decimal "mission_archive_43", precision: 10
    t.decimal "mission_archive_44", precision: 10
    t.decimal "mission_archive_45", precision: 10
    t.float "mission_archive_46"
    t.string "target_month"
    t.integer "job_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
