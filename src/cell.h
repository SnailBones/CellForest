// A 2D array, we'll see if it performs any better!

#ifndef CELL_H
#define CELL_H

#include "rules.h"

#include <Godot.hpp>
#include <Sprite.hpp>

namespace godot
{

class Cell : public Reference
{
	GODOT_CLASS(Cell, Reference);

private:
public:
	int species;
	float height;
	float water;
	float elevation;
	float sediment;
	bool on_fire;
	float test_var; //Just for visualizing

	static void _register_methods();

	Cell();
	~Cell();

	void _init(); // our initializer called by Godot
	void imitate(Cell);

	bool isEmpty();
	bool isATree();
	void die();
	float grow(RULES r, float growSpeed);
	void growD(Dictionary r, float growSpeed);
};

} // namespace godot

#endif