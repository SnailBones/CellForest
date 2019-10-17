# CellForest

A cellular automata biological and geological simulation in C++ and Godot. It also plays music. Download available on [itch.io](https://ailanthus.itch.io/forest).

<img src="img/demo.gif">

# Setup

Since the simulation is programmed in C++ as a GDNative module, setup is a bit complex. I've tested it only on Windows, so other platforms might need a bit of tweaking. Here's the neccesary steps:
* Dowload or clone this repository.
* Pull the [godot-cpp source](https://github.com/GodotNativeTools/godot-cpp) with `git submodule update --init --recursive`
* Consult the [official Godot documentation](https://docs.godotengine.org/en/3.1/tutorials/plugins/gdnative/gdnative-cpp-example.html) to set up additional dependencies for your operating system.
* In the directory you just cloned (`cd godot-cpp`), compile the source. (Something like`scons platform={your platform} generate_bindings=yes`)
* You'll have generated a file called something like `CellForest/godot-cpp/bin//libgodot-cpp.windows.release.debug.default` On windows, you need to add the ".lib" suffx. (This is due to an issue in the Godot's example scons file code I copied, if you know a fix, I'd be happy to hear it.)
* Compile the game with `scons platform=<your platform>`
* Open and run your project in Godot!


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
