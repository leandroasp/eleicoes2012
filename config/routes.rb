ActionController::Routing::Routes.draw do |map|
  map.root   :controller => 'resultados'
  map.result ':turno', :controller => 'resultados', :action => 'uf' 
  map.result ':turno/:estado', :controller => 'resultados', :action => 'city'
  map.result ':turno/:estado/:cidade', :controller => 'resultados', :action => 'show'

  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'
end
