Rails.application.routes.draw do
  resources :work_data do
    collection do
      get :work_data_set
      get :work_data_out
    end
  end
  resources :mission_archives do
    collection do
      get :out_archive_mission
    end
  end
  resources :tworks
  resources :debits do
    collection do
      get :get_job
    end
  end
  resources :cost do
    collection do
      get :cal_cost
    end
  end
  resources :archives do
    collection do
      get :data_set
      get :out_csv
    end
    member do
      post :data_set_one
    end
  end
  get 'sheet_cutter', to: 'sheet_cutter#index'
  get 'calendar', to: 'calendar#index'
  get 'calendar/job_item', to: 'calendar#job_item'
  get 'grids/show'
  patch 'grids/update', to: 'grids#update', as: :update_grid_setting
  get 'suggestions/archives', to: 'suggestions#archives', defaults: { format: :json }
  get 'jobs/download/:id',to: 'jobs#download',as: 'download'

  resources :add_data do
    collection do
      get :edit_parent_code
      patch :update_parent_code
    end
  end
  resources :add_presses
  resources :paper_lists

  resources :add_values do
    collection do
      get :rows
      get :paper_inquiry
      post :paper_inquiry
      get :out_csv
      get :out_mission
      get :mission_data_set
      get :add_papers
      get :set_papers
      get :set_den_code
      get :add_values_search
      match :list_mission, via: [:get, :post]
      get :set_target_month
    end
  end
  resources :press_data do
    collection do
      get :job_link
      get :get_data
      get :indexorg
      get :seisaku
      get :paper
      get :ctp
    end
  end
  resources :size_lists do

  end
  resources :jobs do
    member do
      get :show_org
      get :edit_paper
      get :arrange
      get :arrange_update
    end
    collection do
      get :press_list
    end
  end

  get "welcomes/show"
  root "add_values#index"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

