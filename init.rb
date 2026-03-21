require_relative 'lib/redmine_pin/hooks'

Rails.configuration.to_prepare do
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
end

Redmine::Plugin.register :redmine_pin do
  name 'Redmine Pin plugin'
  author 'Jonas Liubinas (liubinas.jonas@gmail.com)'
  description 'A plugin for pinning Redmine issues'
  version '0.1.0'
  url 'https://github.com/jonasliu95/redmine_pin'
  author_url 'https://github.com/jonasliu95'

  settings default: { 'enabled' => '1' }, partial: 'settings/redmine_pin_settings'

  menu :top_menu, :pins, { controller: 'pins', action: 'index' }, 
       caption: 'Pins', 
       after: :projects,
       if: proc { User.current.logged? && (Setting.plugin_redmine_pin.is_a?(Hash) ? Setting.plugin_redmine_pin['enabled'] == '1' : true) }
       
  permission :view_pins, { pins: [:index, :toggle] }, public: true
end
