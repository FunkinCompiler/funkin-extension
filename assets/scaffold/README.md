# Welcome to Funkin Compiler's template project

[Kade's V-Slice docs](https://thekade.net/funkin-cookbook/)

This is a simple template to get you started with V-Slice modding.
Below is the explanation of the folders in your new mod project

## `assets` folder

This folder houses all assets used by your mod.
This includes any non-code files and .json or .fnfc files.

Check out it's [separate README](./assets/README.md) for more details!

## `source` folder

This folder houses all script files, that will be later compiled with the rest of the files in ``mod_base``.

The structure made in this folder will be replicated in the "scripts" folder of your mod merging with `mod_base/scripts` if you decide to put any scripts outside this template (like song events).

It's recommended to put into `source` folder all files from the "scripts" folder of your existing mod into this one (if you have any).

While doing so remember to:
- change `.hxc` extension to `.hx`
- add a `package <mod_name>.<path>;` line to the beginning of them (your IDE should help you with that)
- Make sure you don't put `package;` by accident somewhere

By default this folder contains:
- ``source/ExampleModule.hx`` Adds a single option to the preferences menu
- ``source/ExampleEvent.hx`` Adds a single event to the Chart editor
- ``source/misc/ExampleModule.hx`` Has some functions used by the ``source/mod/ExampleModule.hx``

## Getting your funkin mod to **funk**

To see your mod in action head over to "Run and Debug" section of your IDE, which has all the necessary tasks to let you playtest your mod:

- `Just run FNF` Starts up your engine (stopping this task will also stop the game. Useful in some cases)
- `Compile & Run FNF mod` Runs `Compile Mod` and `Just run FNF` in one go.
- `Funk: Compile current V-Slice mod` Exports your mod to a v-slice engine located. It'll be put in "funkinGame/mods/workbench" unless otherwise defined.
- `Funk: Export current V-Slice mod` Exports your mod to the "export" folder. Useful for uploading to the gamebanana.

