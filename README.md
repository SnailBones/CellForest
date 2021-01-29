# CellForest

A cellular automata biological and geological simulation in C++ and Godot. It also plays music. Download the game [here](https://ailanthus.itch.io/forest).

<img src="img/demo.gif">

# Setup

Since the simulation is programmed in C++ as a GDNative module, setup is a bit hairy. I've tested it on Windows and Ubuntu. Here's the neccesary steps:
* Dowload or clone this repository.
* Pull the [godot-cpp source](https://github.com/GodotNativeTools/godot-cpp) with `git submodule update --init --recursive`
* Consult the [official Godot documentation](https://docs.godotengine.org/en/stable/tutorials/plugins/gdnative/gdnative-cpp-example.html) to set up additional dependencies for your operating system.
* In the directory you just cloned (`cd godot-cpp`), compile the source. (Something like`scons platform={your platform} generate_bindings=yes [target=release]`)
* You'll have generated a file called something like `CellForest/godot-cpp/bin//libgodot-cpp.windows.debug.default` (The 'debug' will be replaced with 'release' in release mode.) On windows, you need to add the ".lib" suffx. On Linux, you may need to change the ".64" to a ".default" (These issues seem to result from the Godot's example scons file code, if anyone knows a fix, pray tell me!)
* Compile the game with `scons platform=<your platform> [target=release]`
* Open and run the project in Godot! If all went well, it will be ready to play or export.


# License

MIT License

Copyright (c) 2019, Aidan H H

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
