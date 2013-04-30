#encoding: utf-8
#require 'dispatcher'

Redmine::Plugin.register :mec_events do
  name 'Mec Events plugin'
  author 'Author'
  description 'This is a plugin for Redmine that manage events'
  version '0.0.1'
  #url 'http://example.com/path/to/plugin'
  #author_url 'http://example.com/about'


   settings :default => {:empty => false}, :partial => 'mec_events_settings/mec_events_settings'


  project_module :events do
    permission :manage_event_configuration, :event_configuration => [:edit]
  end


  ActionDispatch::Callbacks.to_prepare do 
    unless ProjectsHelper.included_modules.include?(ProjectsHelperPatch)
        ProjectsHelper.send(:include, ProjectsHelperPatch)
    end

    unless ProjectsController.included_modules.include?(ProjectsControllerPatch)
        ProjectsController.send(:include, ProjectsControllerPatch)
    end
  end

end
