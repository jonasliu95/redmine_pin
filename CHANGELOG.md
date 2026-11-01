# Changelog

## 0.2.0 (2026-11-01)

- Pins are now associated with issues and users, so deleting an issue or a user also
  deletes their pins. A one-time migration removes pins left behind by earlier versions.
- `/pins` and the pin toggle respect issue visibility: issues you can no longer see
  disappear from your board and cannot be pinned.
- Disabling the plugin in its settings now disables the feature completely: the menu
  entry, the issue button and both `/pins` endpoints are unavailable.
- An unknown `view_mode` value falls back to the list view instead of raising a
  not-found error.
- The pins board now defaults to "Date added / Descending", matching the preselected
  options in the toolbar.
- The pin button uses Redmine's SVG icon set instead of the undefined `icon-pin`
  classes, and the button and menu are translated in all eight bundled locales.
- Plugin translation keys are prefixed with `redmine_pin_`, so they no longer override
  core Redmine labels such as "Sort".
- A double click or two simultaneous requests no longer produce a 500 error when
  pinning the same issue; the pin is simply created once.
- Added automated tests, stopped tracking `.DS_Store` files and updated the
  installation instructions to include asset precompilation.
