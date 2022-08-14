# World Map Texture Generation Tool - Changelog

## Version v0.9.1
### Changed
* Use the current scene name as default map name.

### Fixed
* Improved error handling in general.
* Set opened scene when enabling the plugin (before "scene_changed" signal is fired).
* The selected item for the texture size is now determined by the index via string comparison when resetting default settings.

## Version v0.9.0 - Initial Version
Generate world map textures from the whole currently opened scene within the provided world size.
