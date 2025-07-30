<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/FunkinCompiler/FunkinCompiler">
    <img src="icon.png" alt="Logo" width="300" height="300">
  </a>

<h3 align="center">Funkin Compiler</h3>

  <p align="center">
    A simple extension to both develop and compile V-Slice mods in a more comfortable environment than a notepad.
    <br />
    <br />
    ·
    <a href="https://github.com/FunkinCompiler/FunkinCompiler/issues">Report Bug or Request Feature</a>
    ·
    <a href="https://github.com/FunkinCompiler/FunkinCompiler/pulls">Create Pull Request</a>
  </p>
</div>

## How to Install

1. Install both Haxe and Git
2. Use ``haxelib setup`` to create an empty repo for dependencies.
3. Download the program (either from releases or a action build)
 - The program will remind you if you forget to install either Haxe or Git
4. Run it (On linux you have to run it from the console)
 - The program doesn't contain any GUI, so everything will be done from the console
5. select  `setup` from the menu
6. Once done, you can customise some settings from ``funk.cfg`` file.
> Note: filepaths are based on your project's root dorectory
 - ``mod_content_folder`` Points to your mod's base folder. 
 All the files here will copied first when compiling your mod.
 - ``mod_hx_folder`` Point to your code managed, and then compiled by the program.
 This is where you write your code.
 - ``mod_fnfc_folder`` Points to the FNFC files of your mod. 
 Those get properly integrated into your mod when compiling.
 This lets you easily edit the songs from the game itself.
 - ``game_mod_name`` Is the name of your mod in the game instance
 avaliable from the "mods" folder.
 - ``game_path`` Path to the game folder.

## How to use

#### Making a new project

To create a new project, run the program select `new`. 
You will be prompter for it's name and you can now start working on your mod.

#### Working on the project

- Open the newly created project in VSCode or a fork based on it. 
- Head over to the extensions tab and install all of the recomended extensions.

- click the "HTML5" text on the bottom bar (if present) and change it to your sys platform (either linux or windows)
- Initialise a new git repo and add at least one commit and add all files to it (I recommend to use VSCode for that)

Be sure to either restart VSCode or reload the window for the changes to take effect. After that you should be ready to go!
[Here is a TTW file documenting the project's structure](./GETTING_STARED.md)
