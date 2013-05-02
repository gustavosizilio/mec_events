require_dependency 'projects_controller'

module ProjectsControllerPatch

    def self.included(base)
        base.extend(ClassMethods)
        base.send(:include, InstanceMethods)
        base.class_eval do
            unloadable
            alias_method_chain :settings, :event_configuration
        end
    end

    module ClassMethods
    end

    module InstanceMethods

        def settings_with_event_configuration
            result = settings_without_event_configuration
            @event_configuration = EventConfiguration.where(:project_id => @project.id).first
            @event_configuration ||= EventConfiguration.new
            return result
        end

    end

end
