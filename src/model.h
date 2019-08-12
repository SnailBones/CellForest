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
	Grid last_state;
	Grid next_state;
	Grid *const next_state_pointer = &next_state;

public:
	static void _register_methods();

	Model();
	~Model();

	void _init(); // our initializer called by Godot

	void resize(int w, int h);

	void growAll();
	void flowAll(float rain);
	// Ref<Grid> getState();
	Grid *getState();
	void setState(Grid *v);
	void setCell(int x, int y, Cell *v);
	Cell *getCell(int x, int y);
};
} // namespace godot

#endif