require_dependency 'projects_helper'

module ProjectsHelperPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
            alias_method_chain :project_settings_tabs, :mec_events
        end
    end

    module ClassMethods
    end

    module InstanceMethods

        def project_settings_tabs_with_mec_events
            tabs = project_settings_tabs_without_mec_events
            tabs.push({ :name => 'events',
                        :action => :manage_event_configuration,
                        :partial => 'mec_events_settings/projects_settings',
                        :label => :events}) if User.current.allowed_to?(:manage_event_configuration, @project)
            return tabs
        end

    end

end
