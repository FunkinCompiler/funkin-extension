<!-- PROJECT LOGO -->
<br />
<div align="center">
 <a href="https://github.com/FunkinCompiler/funkin-extension">
 <img src="assets/icon.png" alt="Logo" width="300" height="300">
 </a>

<h3 align="center">Funkin Compiler</h3>

 <p align="center">
 A simple extension to both develop and compile V-Slice mods in a more comfortable environment than a notepad.
 <br />
 <br />
 ·
 <a href="https://github.com/FunkinCompiler/funkin-extension/issues">Report Bug or Request Feature</a>
 ·
 <a href="https://github.com/FunkinCompiler/funkin-extension/pulls">Create Pull Request</a>
 </p>
</div>
<h2 align="center">This extension is still in beta</h2>

# Features (as of now)

- .json schema hints
- Automatic .fnfc extraction
- Nearly all features of Haxe's autocompletion server, including:
- - Code autocompletion
- - Code formatting
- - Type hints
- - Static error checking
- - "Go to definition" function with Ctrl+click on function/class

It's essentially the implementation of [this](https://github.com/FunkinCrew/Funkin/issues/5199) suggestion.

## How to Install

1. Install both Haxe and Git
2. Use ``haxelib setup`` to create an empty repo for dependencies.
3. Install the extension.
4. Run `Funkin: Setup Funkin compiler` command to install necessary dependencies.
5. Once done, open a new **empty** folder
6. Run `Funkin: Make new project` to scaffold template for your mod.
7. Once done, you can customise some settings from ``funk.cfg`` file.
> Note: filepaths are based on your project's root directory
 - ``mod_content_folder`` Points to your mod's base folder.
 All the files here will be copied first when compiling your mod.
 - ``mod_hx_folder`` Point to your code managed and then compiled by the program.
 This is where you write your code.
 - ``mod_fnfc_folder`` Points to the FNFC files of your mod.
 Those get properly integrated into your mod when compiling.
 This allows you to easily edit the songs from the game itself.



## How to use

#### Making a new project

To create a new project, run the `Funkin: Make new project` command in an empty folder.

#### Customising the extension
The extension adds the new task type: ``funk``,
new debugger type ``funkin-run-game``


And the following settings (apply as default settings for the compile task):
 - ``funkinCompiler.modName`` Is the name of your mod in the game instance
 available from the "mods" folder.
 - ``funkinCompiler.gamePath`` Path to the game folder.

#### Working on the project

- Open the newly created project in VSCode or a fork based on it.
- Head over to the extensions tab and install all of the recommended extensions.

- Initialise a new git repo and add at least one commit, and add all files to it (I recommend using VSCode for that)

Be sure to either restart VSCode or reload the window for the changes to take effect. After that, you should be ready to go!
[Here is a TTW file documenting the project's structure](./GETTING_STARED.md)

## How to compile

Make sure to install both `vscode` and `vscode-debugadapter` haxelibs.

As for the node, run `npm install vscode-debugadapter` to install dependencies for the debugger.

#### Not asossiated with "Funkin' Crew" btw.
