Rails.application.routes.draw do

  resources :switch_initial_configs
  resources :switches


  get 'monitor_glue/status'

  get 'sdn_callback/restore_state'

  match 'net_config_transactions/sort' => 'net_config_transactions#sort', :via=>[:get, :post]
  resources :net_config_transactions, :only => [:index]
  
  get 'owner_group/index'
  get 'group/index'

  get 'admin/index'
  get 'admin'=>'admin#index'
  get 'admin/subnets'
  get 'admin/initialize_sdn_controller'
  get 'admin/playback_to_sdn'
  get 'admin/get_sdn_config'
  get 'admin/ajax_get_groups'
  post 'admin/ajax_set_group'
  get 'admin/ajax_get_members'
  post 'admin/add_subnet'
  get 'admin/links'
  delete 'admin/not_supported'
  
  get 'admin/visualize_switch_setup'
  get 'admin/d3_switch_setup'
  get 'admin/switch_setup'
  
  
  get 'home/logout'=>'home#logout'
  get "no_access" => 'home#no_access'
  get 'home/visualize_sdn'
  get 'home/d3_sdn'
  get 'home/sdn_status'
  
  root 'link_requests#index_get'
  match 'link_requests' => 'link_requests#index_get', :via=>[:get]
  
  post "link_requests/approve"
  post "link_requests/deny"  
  match 'link_requests/sort' => 'link_requests#sort', :via=>[:get, :post]
  resources :link_requests

  get "owner_group/ajax_users"
  post "owner_group/rm_user"
  post 'owner_group/add_user'
  match 'owner_group/sort' => 'owner_group#sort', :via=>[:get, :post]
  resources :owner_group
  

  get "activities/sort"
  resources :activities
  
  resources :links
  
end
