# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
match 'projects/:id/event_configuration', :to => 'event_configuration#edit', :via => :post
match 'projects/:id/event_configuration/destroy', :to => 'event_configuration#destroy', :via => [:get, :post]
