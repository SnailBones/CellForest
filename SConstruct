#!python
import os
import subprocess

opts = Variables([], ARGUMENTS)

# clangity clang clang
clang_path = "C:\\Program Files\\LLVM\\bin"

# Gets the standard flags CC, CCX, etc.
env = DefaultEnvironment()
# env = DefaultEnvironment(ENV={'PATH': os.environ['PATH']})
# env = Environment(ENV=os.environ)

# clangity clang clang
# env.Append(PATH=path)
# env.Append(PATH=os.environ['PATH'])

# all_paths = env.Dictionary('PATH')
# all_paths = env['ENV']['PATH']
# print(all_paths)
# print("path in all_paths is " + str(path[0] in all_paths))


# Define our options
opts.Add(EnumVariable('target', "Compilation target",
                      'debug', ['d', 'debug', 'r', 'release']))
opts.Add(EnumVariable('platform', "Compilation platform",
                      '', ['', 'windows', 'x11', 'linux', 'osx']))
opts.Add(EnumVariable('p', "Compilation target, alias for 'platform'",
                      '', ['', 'windows', 'x11', 'linux', 'osx']))
opts.Add(BoolVariable('use_llvm', "Use the LLVM / Clang compiler", 'no'))
opts.Add(PathVariable('target_path',
                      'The path where the lib is installed.', 'CellForest/bin/'))
# opts.Add(PathVariable('target_name', 'The library name.', 'libgdexample', PathVariable.PathAccept))
opts.Add(PathVariable('target_name', 'The library name.',
                      'cell', PathVariable.PathAccept))
# Local dependency paths, adapt them to your setup
godot_headers_path = "godot-cpp/godot_headers/"
cpp_bindings_path = "godot-cpp/"
cpp_library = "libgodot-cpp"

# only support 64 at this time..
bits = 64

# Updates the environment with the option variables.
opts.Update(env)

# Process some arguments
if env['use_llvm']:
    env['CC'] = 'clang'
    env['CXX'] = 'clang++'

    # Added this, trying to make clang work
    # env['PATH'] = os.environ['PATH']
    # env['tools'] = ['clang++']
    env.AppendENVPath('PATH', clang_path)

if env['p'] != '':
    env['platform'] = env['p']

if env['platform'] == '':
    print("No valid target platform selected.")
    quit()

# For the reference:
# - CCFLAGS are compilation flags shared between C and C++
# - CFLAGS are for C-specific compilation flags
# - CXXFLAGS are for C++-specific compilation flags
# - CPPFLAGS are for pre-processor flags
# - CPPDEFINES are for pre-processor defines
# - LINKFLAGS are for linking flags

# Check our platform specifics
if env['platform'] == "osx":
    env['target_path'] += 'osx/'
    cpp_library += '.osx'
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS=['-g', '-O2', '-arch', 'x86_64'])
        env.Append(LINKFLAGS=['-arch', 'x86_64'])
    else:
        env.Append(CCFLAGS=['-g', '-O3', '-arch', 'x86_64'])
        env.Append(LINKFLAGS=['-arch', 'x86_64'])

elif env['platform'] in ('x11', 'linux'):
    env['target_path'] += 'x11/'
    cpp_library += '.linux'
    if env['target'] in ('debug', 'd'):
        env.Append(CCFLAGS=['-fPIC', '-g3', '-Og'])
    else:
        env.Append(CCFLAGS=['-fPIC', '-g', '-O3'])
    env.Append(CXXFLAGS=['-std=c++17'])


elif env['platform'] == "windows":
    env['target_path'] += 'win64/'
    cpp_library += '.windows'

    # This makes sure to keep the session environment variables on windows,
    # that way you can run scons in a vs 2017 prompt and it will find all the required tools
    env.Append(ENV=os.environ)

    env.Append(CPPDEFINES=['WIN32', '_WIN32',
                           '_WINDOWS', '_CRT_SECURE_NO_WARNINGS'])
    env.Append(CCFLAGS=['-W3', '-GR'])
    # MD needs the runtime libraries as a DLL, MT (and MTd) includes them as a static library.
    # This needs to be consistent with the way that godot-cpp is compiled.
    if env['target'] in ('debug', 'd'):
        env.Append(CPPDEFINES=['_DEBUG'])
        # env.Append(CCFLAGS=['-EHsc', '-MDd', '-ZI'])
        env.Append(CCFLAGS=['-EHsc', '-MTd', '-ZI'])
        env.Append(LINKFLAGS=['-DEBUG'])
    else:
        env.Append(CPPDEFINES=['NDEBUG'])
        # env.Append(CCFLAGS=['-O2', '-EHsc', '-MD'])
        env.Append(CCFLAGS=['-O2', '-EHsc', '-MT'])

if env['target'] in ('debug', 'd'):
    cpp_library += '.debug'
else:
    cpp_library += '.release'

cpp_library += '.' + str(bits)
# For windows change the above line to this, or change the name of the file:
# cpp_library += '.default'

# make sure our binding library is properly includes
env.Append(CPPPATH=['.', godot_headers_path, cpp_bindings_path + 'include/',
                    cpp_bindings_path + 'include/core/', cpp_bindings_path + 'include/gen/'])
env.Append(LIBPATH=[cpp_bindings_path + 'bin/'])
env.Append(LIBS=[cpp_library])

# tweak this if you want to use different folders, or more folders, to store your source code in.
env.Append(CPPPATH=['src/'])
sources = Glob('src/*.cpp')

# env.Append(CXXFLAGS='/std:c++latest')
# Neccesary for functions like std::clamp
# env.Append(CXXFLAGS='/std:c++14')

library = env.SharedLibrary(
    target=env['target_path'] + env['target_name'], source=sources)

Default(library)

# Generates help for the -h scons option.
Help(opts.GenerateHelpText(env))
