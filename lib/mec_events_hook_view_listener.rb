class MecEventsHookViewListener < Redmine::Hook::ViewListener
  render_on :view_issues_show_details_bottom, :partial => "events/links"
end
