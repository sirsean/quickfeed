Quickfeed::Application.routes.draw do
  match "home" => "home#index"
  get "home/index"

  match "export" => "export#index"
  get "export/index"
  get "export/subscriptions"

  match "import" => "import#index"
  get "import/index"
  post "import/upload"

  match "group" => "group#index"
  get "group/index"
  get "group/new"
  post "group/new"
  match "group/show/:group_id" => "group#show"
  match "group/edit/:group_id" => "group#edit"
  match "group/delete/:group_id" => "group#delete"
  match "group/remove_feed/:group_id/:feed_id" => "group#remove_feed"
  match "group/order/:group_id/:direction" => "group#order"
  match "group/merge/:group_id" => "group#merge"

  match "subscribe" => "subscribe#index"
  get "subscribe/index"
  match "subscribe/complete/:feed_id" => "subscribe#complete"

  get "user/login"
  post "user/login"
  get "user/logout"
  get "user/register"
  post "user/register"
  match "user/show/:username" => "user#show"
  get "user/edit"
  post "user/edit"
  get "user/passwd"
  post "user/passwd"

  get "api/groups"
  get "api/items"
  post "api/add_feed"
  post "api/read_items"

  match "reader" => "reader#index"
  get "reader/index"

  root :to => "home#index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
