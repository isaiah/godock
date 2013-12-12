ClojuredocsPg::Application.routes.draw do
  devise_for :users, :path => "", :path_names => { :sign_in => 'login', :sign_out => 'logout' }, :controllers => { :sessions => "sessions" }

  resources :users
  resources :remarks

  get '/profile/:login' => 'users#profile', as: "user_profile"
  get '/search_autocomplete' => 'main#search_autocomplete'
  get '/search' => 'main#search'
  get '/search/:lib' => 'main#search'
  get '/ac_search' => 'main#lib_search'
  get '/ac_search/:lib' => 'main#lib_search'
  resources :examples
  resources :comments
  get '/quickref/:lib' => 'main#quick_ref_shortdesc'
  get '/quickref/shortdesc/:lib' => 'main#quick_ref_shortdesc'
  get '/quickref/varsonly/:lib' => 'main#quick_ref_vars_only'
  get '/feed/recent_updates' => 'feed#recent_updates'
  get '/see_also/lookup' => 'see_also#lookup'
  get '/see_also/delete' => 'see_also#delete'
  get '/see_also/vote' => 'see_also#vote'
  get '/see_also/add' => 'see_also#add'
  get '/v/:id' => 'main#function_short_link'
  get '/libs' => 'main#libs'
  get '/management/search/:lib' => 'management#search'
  get '/management/:lib/function' => 'management#function'
  get '/management/:lib' => 'management#index'
  get '/:lib/:version' => 'main#lib', :constraints => { :version => /\d+\.[^\/]*/ }
  get '/:lib/:version/builtin/(:type_class)$(:function)' => 'main#function', constraints: { version: /\d+\.[^\/]*/ }
  get '/:lib/:version/builtin/:type_class' => 'main#type_class', constraints: { :version => /\d+\.[^\/]*/}
  get '/:lib/:version/*ns/:type_class' => 'main#type_class', constraints: { :version => /\d+\.[^\/]*/, ns: /\w+(\/\w+)*?/, type_class: /[A-Z]+\w+/ }
  get '/:lib/:version/*ns/(:type_class)$(:function)' => 'main#function', constraints: { version: /\d+\.[^\/]*/, ns: /\w+(\/\w+)*?/, type_class: /[A-Z]+\w+/ }
  get '/:lib/:version/(*ns)$(:function)' => 'main#function', :constraints => { :version => /\d+\.[^\/]*/ }
  get '/:lib/:version/*ns' => 'main#ns', :constraints => { :version => /\d+\.[^\/]*/ }
  get '/:lib' => 'main#lib'
  get '/:lib/builtin/(:type_class)$(:function)' => 'main#function', constraints: { ns: /\w+(\/\w+)*?/ }
  get '/:lib/builtin/:type_class' => 'main#type_class', constraints: { ns: /\w+(\/\w+)*?/ }
  get '/:lib/*ns/:type_class' => 'main#type_class', constraints: { ns: /\w+(\/\w+)*?/, type_class: /[A-Z]+\w+/ }
  get '/:lib/*ns/(:type_class)$(:function)' => 'main#function', constraints: { ns: /\w+(\/\w+)*?/, type_class: /[A-Z]+\w+/ }
  get '/:lib/(*ns)$(:function)' => 'main#function', constraints: { ns: /\w+(\/\w+)*?/ }
  get '/:lib/*ns' => 'main#ns'
  root :to => "main#index"
end

