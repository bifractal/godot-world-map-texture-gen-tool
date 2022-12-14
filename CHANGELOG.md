# World Map Texture Generation Tool - Changelog

## Version v0.9.4
### Fixed
* Depth resoultion by increasing camera's near value.

## Version v0.9.3
### Added
* Generation progress dialog.
* Viewport background transparency checkbox.
* Notification dialog on empty scenes.

### Changed
* Removed default map name. Set placeholder to current scene name instead.

## Version v0.9.2
### Changed
* Set Viewport background to be non-transparent to fix image glitches.

## Version v0.9.1
### Changed
* Use the current scene name as default map name.

### Fixed
* Improved error handling in general.
* Set opened scene when enabling the plugin (before "scene_changed" signal is fired).
* The selected item for the texture size is now determined by the index via string comparison when resetting default settings.

## Version v0.9.0 - Initial Version
Generate world map textures from the whole currently opened scene within the provided world size.
