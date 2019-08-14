#ifndef MODEL_H
#define MODEL_H

#include <Godot.hpp>
#include <Sprite.hpp>

#include "model.h"
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
	Grid* last_state;
	Grid* next_state;
	// Grid state1;
	// Grid state2;
	// Two states are swapped between pointers for performance
	void swapStates();

public:
	static void _register_methods();

	Model();
	~Model();

	void _init(); // our initializer called by Godot

	// void setup(int w, int h);
	void setup(int width, int height, float speed, Dictionary birch, Dictionary spruce, Dictionary water, Dictionary fire);

	// void growAll();
	bool growAll();
	void growCell(int x, int y, float speed);
	bool flowAll(float rain);
	// void flowAll(float rain);
	void flowCell(int x, int y, float rain);
	// Ref<Grid> getState();
	Grid *getState();
	void setState(Grid *v);
	void setCell(int x, int y, Cell *v);
	Cell *getCell(int x, int y);
};
} // namespace godot

#endif