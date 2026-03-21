# Redmine Pin Plugin

A Redmine plugin that allows users to independently pin their favorite issues to a private pin board for quick access.

Compatible with Redmine 6.X and 5.X versions.

## Screenshots

### Pinning an Issue
![Pinning an issue](pictures/pin.png)

### Pin Board (Grid View)
![Pins Grid View](pictures/pingrid.png)

### Pin Board (List View)
![Pins List View](pictures/pinlist.png)

### Plugin Settings
![Plugin Settings](pictures/settings.png)

## Features

- Add and manage pinned tasks with a single click inside any issue.
- Dedicated "Pins" dashboard available in the top menu.
- Display pins in a classic List view or a modern Grid view.
- Group, sort, and filter your favorite tasks by project, date, status, priority, subject, and assignee.
- Instant AJAX unpinning from the Pins dashboard.

## Installation

1. Copy the plugin directory to your Redmine `plugins` folder:
   ```bash
   cd /path/to/redmine/plugins
   git clone https://github.com/jonasliu95/redmine_pin.git
   ```

2. Run the plugin migrations:
   ```bash
   cd /path/to/redmine
   bundle exec rake redmine:plugins:migrate RAILS_ENV=production
   ```

3. Restart your Redmine instance:
   ```bash
   # For Passenger
   touch tmp/restart.txt

   # For other servers, restart accordingly
   ```

4. Go to **Administration → Plugins** to verify the plugin is loaded.

## Configuration

1. Navigate to **Administration → Plugins**
2. Find "Redmine Pin plugin" and click **Configure**
3. Ensure the plugin is enabled.
4. Save settings.

## Usage

1. Open any issue in your Redmine instance.
2. Click the **Pin** button located in the contextual menu (next to Edit, Log time, Copy).
3. Click the **Pins** menu item in the top navigation bar to access your personal pin board.
4. From the Pins dashboard, you can view your pinned issues, toggle between Grid and List views, sort, group, and unpin tasks.

## Compatibility

| Locale | Status |
|--------|--------|
| en     | Full support |
| lt     | Full support |
| de     | Not supported |
| es     | Not supported |
| fr     | Not supported |
| it     | Not supported |
| ja     | Not supported |
| ru     | Not supported |

Not supported means that the plugin is translated, but without proper QA of the translation.

## Translations

To add a new translation, simply copy the `config/locales/en.yml` file to your desired language code (e.g., `de.yml`) and translate the values. Contributions via pull requests are highly encouraged!

## Upgrade

```bash
cd /path/to/redmine/plugins/redmine_pin
git pull
cd /path/to/redmine
bundle exec rake redmine:plugins:migrate RAILS_ENV=production
touch tmp/restart.txt
```

## Uninstall

```bash
cd /path/to/redmine
bundle exec rake redmine:plugins:migrate NAME=redmine_pin VERSION=0 RAILS_ENV=production
rm -rf plugins/redmine_pin
touch tmp/restart.txt
```

## Support

For issues and feature requests, please visit: [GitHub Issues](https://github.com/jonasliu95/redmine_pin/issues)

Improvements are widely accepted! If you have any suggestions, bug reports, or translation updates, please open an issue in GitHub.

## License

This plugin is released under the MIT License.
