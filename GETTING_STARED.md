# Getting started

There are many approaches you could take from this point on.
Instead, I'll guide you through the most important parts of this template:

## `mod_base` folder

This folder contains all non-code assets of your mod. If you're working with an already existing mod, then that's the place for all the files of the mod.

Think of it as a "base" for your mod to which then you can add things by either writing code or putting .fnfc files into `fnfc_files`.

It's still possible to put additional .hxc files into `mod_base/scripts` like custom song events or scripts you find on the internet, which you want to use.

## `mod_base/data` folder

This folder houses all data-related things of your mod. For most of them you can simply create a JSON file in a desired sub-folder and use included JSON schemas to create a said data object (for now works with levels, stages and characters).

## `fnfc_files` folder

This folder stores all songs used by the mod in `.fnfc` format. Those get compiled with the rest of your code.

You are still able to manually extract necessary files, but it's recommended to avoid doing that (mostly due to cleanness and ease of editing).

You can also create sub-directories for your songs. It doesn't have any other purpose than letting you structure your songs.

## `source/mod` folder

This folder houses all script files, that will be later compiled with the rest of the files in `mod_base``.

The structure made in this folder will be replicated in the "scripts" folder of your mod merging with `mod_base/scripts` if you decide to put any scripts outside this template (like song events).

It's recommended to put into `source/mod` folder all files from the "scripts" folder of your existing mod into this one (if you have any).

While doing so remember to:
- change `.hxc` extension to `.hx`
- add a `package` line to the beginning of them (your IDE should help you with that)

## Getting your funkin mod to **funk**

To see your mod in action head over to "Run and Debug" section of your IDE, which has all the necessary tasks to let you playtest your mod:
> The output is in *Terminal* tab and **not in Debug Console** (which is opened by default for some reason)
- `Download assets` *no need to use this at this point*
- `Compile Mod` Exports your mod to a v-slice engine located in "funkinGame". It'll be put in "funkinGame/mods/workbench" unless otherwise defined in "Test.hx".
- `Launch Mod` Starts up your engine (stopping this task will also stop the game. Useful in some cases)
- `Compile&Launch mod` Runs `Compile Mod` and `Launch Mod` in one go.
- `Export Mod` Packs your mod into a .zip file and drops it in the root directory. You can choose its name and set a new version for your mod (if you keep forgetting about it like I do)
