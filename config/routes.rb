# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html
match 'projects/:id/event_configuration', :to => 'event_configuration#edit', :via => :post, :as => 'save_event_configuration'
match 'projects/:id/event_configuration/destroy', :to => 'event_configuration#destroy', :via => [:get, :post]

match 'issues/:id/send_invitations', :to => 'events#send_invitations', :via => :post, :as => 'send_invitations'
match 'issues/:id/confirm_invitation', :to => 'events#confirm_invitation', :via => :post, :as => 'confirm_invitation'
get 'issues/:id/new_invitations_with_confirmation', :to => 'events#new_invitations_with_confirmation'

