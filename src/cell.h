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
	// int species;
	// float height;
	// float water;
	// float elevation;
	// float sediment;
	// bool on_fire;
	// float stress; //Just for visualizing

	float amplitude;
	float speed;
	float time_passed;

public:
	int species;
	float height;
	float water;
	float elevation;
	float sediment;
	bool on_fire;
	float stress; //Just for visualizing

	static void _register_methods();

	Cell();
	~Cell();

	void _init(); // our initializer called by Godot
	void imitate(Cell);

	// void _process(float delta);

	// struct rules
	// {
	// 	float burnRate = .1;
	// 	float waterToLive = .1;
	// 	float portionTaken = .1;
	// 	// float grow;
	// 	float growRate;
	// 	float waterToGrow;
	// 	// float portionTaken;
	// };

	bool isEmpty();
	bool isATree();
	void die();
	void grow(RULES r, float growSpeed);
	void growD(Dictionary r, float growSpeed);
};

} // namespace godot

#endif