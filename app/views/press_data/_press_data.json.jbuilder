json.extract! press_data, :id, :den_code, :product_name, :paper_no, :start_time, :work_time, :n01, :n02, :machine, :created_at, :updated_at
json.url press_data_url(press_data, format: :json)
