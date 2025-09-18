# Assets structure

### ``mod_base``

This folder contains all non-code assets of your mod. If you're working with an already existing mod, then that's the place for all the files of the mod.

Think of it as a "base" for your mod to which then you can add things by either writing code or putting .fnfc files into `fnfc_files`.

It's still possible to put additional .hxc files into `mod_base/scripts` like custom song events or scripts you find on the internet, which you want to use within the Funkin compiler.

### `mod_base/data` folder

This folder houses all data-related things of your mod. For most of them you can simply create a JSON file in a desired sub-folder and use included JSON schemas to create a said data object (for now works with levels, stages and characters).

### `fnfc_files`

This folder stores all songs used by the mod in `.fnfc` format. Those get compiled with the rest of your code.

You are still able to manually extract necessary files, but it's recommended to avoid doing that (mostly due to cleanness and ease of editing).

You can also create sub-directories for your songs. It doesn't have any other purpose than letting you structure your songs.