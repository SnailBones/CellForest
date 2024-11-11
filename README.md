# A Tree Falls: the musical.

A cellular automata-powered ecological and geological simulation in C++ and Godot that plays live, procedurally generated music. Download the game [here](https://ailanthus.itch.io/forest).

<img src="img/demo.gif">

# Setup
If for some inconceivable reason you'd like to build the game from source, here's instructions. Since the simulation is programmed in C++ as a GDNative module, setup is a hairier than a pure Godot game. But I've pulled it off on Windows, MacOS, and Ubuntu. Here's the steps:
* Dowload or clone this repository.
* Pull the [godot-cpp source](https://github.com/GodotNativeTools/godot-cpp) with `git submodule update --init --recursive`
* Consult the [official Godot documentation](https://docs.godotengine.org/en/stable/tutorials/plugins/gdnative/gdnative-cpp-example.html) to set up additional dependencies for your operating system.
* In the directory you just cloned (`cd godot-cpp`), compile the source. (Something like`scons platform={your platform} generate_bindings=yes [target=release] [-j <cores>]`)
* You'll have generated a file called something like `CellForest/godot-cpp/bin/libgodot-cpp.windows.debug.default` (The 'debug' will be replaced with 'release' in release mode.) On windows, you need to add the ".lib" suffx. On Linux, you may need to change the ".64" to a ".default" (These issues seem to result from the Godot's example scons file code, if anyone knows a fix, pray tell me!)
* Compile the game with `scons platform=<your platform> [target=release]`
* Open and run the project in Godot! If all went well, it will be ready to play or export.
