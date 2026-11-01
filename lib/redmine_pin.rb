module RedminePin
  # The plugin is enabled unless the setting explicitly says otherwise.
  def self.enabled?
    setting = Setting.plugin_redmine_pin
    return true unless setting.is_a?(Hash)

    setting['enabled'] == '1'
  end
end
