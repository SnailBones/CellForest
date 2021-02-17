#ifndef GRID_H
#define GRID_H

#include <Godot.hpp>
#include <Sprite.hpp>

#include "cell.h"
#include "rules.h"

// struct cell {
//     int species;
//     double height;
// } ;

namespace godot
{

class Grid : public Reference
{
	GODOT_CLASS(Grid, Reference)

	// class Grid : public Node
	// {
	// GODOT_CLASS(Grid, Node)

private:
	Cell ***grid; //Dynamic 2array of pointers to object

public:
	static void _register_methods();
	int width;
	int height;

	Grid();
	~Grid();

	void _init(); // our initializer called by Godot

	void init(int w, int h);
	void setup(int x, int y);
	void imitate(Grid *grid);

	void _process(float delta);
	void setCell(int x, int y, Cell *val);
	Cell *grow(int x, int y, float speed, RULES spruce, RULES birch, FIRE fire);
	Cell *flow(int x, int y, float rain, WATER water);
	// Ref<Cell> flow(int x, int y, float rain);
	void setCellRef(int x, int y, Ref<Cell> val);
	Ref<Cell> getCellRef(int x, int y);
	void S(godot::Array a, Cell *val);
	Cell *getCell(int x, int y);
	Cell *getLooping(int x, int y);
	Cell **getNeighbors(int x, int y);
	Cell **getMoreNeighbors(int x, int y);

	void lorax(int x, int y);
};

} // namespace godot

#endif