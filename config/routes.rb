ClojuredocsPg::Application.routes.draw do
  devise_for :users, :path => "", :path_names => { :sign_in => 'login', :sign_out => 'logout', :password => 'secret', :confirmation => 'verification', :unlock => 'unblock', :registration => 'register', :sign_up => 'cmon_let_me_in' }, :controllers => { :sessions => "sessions" }

  match '/examples_style_guide' => 'main#examples_style_guide'
  match '/profile/:login' => 'user#profile'
  match '/search_autocomplete' => 'main#search_autocomplete'
  match '/search' => 'main#search'
  match '/search/:lib' => 'main#search'
  match '/ac_search' => 'main#lib_search'
  match '/ac_search/:lib' => 'main#lib_search'
  match '/examples/view_changes/:id' => 'examples#view_changes'
  resources :examples
  resources :comments
  match '/quickref/:lib' => 'main#quick_ref_shortdesc'
  match '/quickref/shortdesc/:lib' => 'main#quick_ref_shortdesc'
  match '/quickref/varsonly/:lib' => 'main#quick_ref_vars_only'
  match '/feed/recent_updates' => 'feed#recent_updates'
  match '/see_also/lookup' => 'see_also#lookup'
  match '/see_also/delete' => 'see_also#delete'
  match '/see_also/vote' => 'see_also#vote'
  match '/see_also/add' => 'see_also#add'
  match '/v/:id' => 'main#function_short_link'
  match '/libs' => 'main#libs'
  match '/management/search/:lib' => 'management#search'
  match '/management/:lib/function' => 'management#function'
  match '/management/:lib' => 'management#index'
  match '/:lib/:version' => 'main#lib', :constraints => { :version => /\d+\.[^\/]*/ }
  match '/:lib/:version/*ns/t/:type_class' => 'main#type_class', constraints: { :version => /\d+\.[^\/]*/, ns: /\w+(\/\w+)*?/, type_class: /[A-Z]\w+/ }
  match '/:lib/:version/*ns/:function' => 'main#function', :constraints => { :version => /\d+\.[^\/]*/, function: /[A-Z]\w+/ }
  match '/:lib/:version/*ns' => 'main#ns', :constraints => { :version => /\d+\.[^\/]*/ }
  match '/:lib' => 'main#lib'
  match '/:lib/*ns/t/:type_class' => 'main#type_class', constraints: { ns: /\w+(\/\w+)*?/, type_class: /[A-Z]\w+/ }
  match '/:lib/*ns/t/:type_class/:function' => 'main#function', constraints: { ns: /\w+(\/\w+)*?/, type_class: /[A-Z]\w+/ }
  match '/:lib/*ns/:function' => 'main#function', constraints: { ns: /\w+(\/\w+)*?/, function: /[A-Z]\w+/ }
  match '/:lib/*ns' => 'main#ns'
  root :to => "main#index"
end

