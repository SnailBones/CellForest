#ifndef MODEL_H
#define MODEL_H

#include <Godot.hpp>
#include <Sprite.hpp>

#include "state.h"
#include "grid.h"
#include "cell.h"

namespace godot
{

class Model : public Node
{
	GODOT_CLASS(Model, Node)

private:
	int width;
	int height;
	float speed;
	Grid *last_state;
	Grid *next_state;
	// Two states must be allocated at runtime to prevent crash
	// States are swapped between pointers for performance
	void swapStates();

public:
	static void _register_methods();

	Model();
	~Model();

	void _init();

	void setup(int width, int height, float speed, Dictionary birch, Dictionary spruce, Dictionary water, Dictionary fire);

	godot::Variant growAll();
	void flowAll(float rain);
	// bool growAll();
	// bool flowAll(float rain);
	void growCell(int x, int y, float speed, State &st);
	void flowCell(int x, int y, float rain);

	void printTotals();

	// Ref<Grid> getState();
	Grid *getState();
	void setState(Grid *v);
	void setCell(int x, int y, Cell *v);
	Cell *getCell(int x, int y);
};
} // namespace godot

#endif