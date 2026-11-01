require_relative 'lib/redmine_pin/hooks'

# Redmine::PluginLoader runs every plugin init.rb inside its own
# Rails.configuration.to_prepare block, so the associations can be attached
# directly here instead of nesting another to_prepare callback.
unless Issue.reflect_on_association(:pins)
  Issue.class_eval do
    has_many :pins, dependent: :destroy
  end
end

unless User.reflect_on_association(:pins)
  User.class_eval do
    has_many :pins, dependent: :destroy
  end
end

Redmine::Plugin.register :redmine_pin do
  name 'Redmine Pin plugin'
  author 'Jonas Liubinas (liubinas.jonas@gmail.com)'
  description 'A plugin for pinning Redmine issues'
  version '0.1.0'
  url 'https://github.com/jonasliu95/redmine_pin'
  author_url 'https://github.com/jonasliu95'
  requires_redmine version_or_higher: '6.0.0'

  settings default: { 'enabled' => '1' }, partial: 'settings/redmine_pin_settings'

  menu :top_menu, :pins, { controller: 'pins', action: 'index' },
       caption: :label_redmine_pin_pins,
       after: :projects,
       if: proc { User.current.logged? && RedminePin.enabled? }
end
