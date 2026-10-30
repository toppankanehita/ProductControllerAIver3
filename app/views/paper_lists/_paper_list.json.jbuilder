json.extract! paper_list, :id, :name, :full_name, :ren, :han, :paper_type_id, :created_at, :updated_at
json.url paper_list_url(paper_list, format: :json)
