// A small bit of code to tell Godot about all the NativeScripts in our GDNative plugin

#include "grid.h"
#include "cell.h"
#include "model.h"

extern "C" void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *o)
{
	godot::Godot::gdnative_init(o);
}

extern "C" void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *o)
{
	godot::Godot::gdnative_terminate(o);
}

extern "C" void GDN_EXPORT godot_nativescript_init(void *handle)
{
	godot::Godot::nativescript_init(handle);
	
	// now we register every class in our library
	godot::register_class<godot::Cell>();
	godot::register_class<godot::Grid>();
	godot::register_class<godot::Model>();
}