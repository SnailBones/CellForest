#include "model.h"
// #include "rules.h"

#include <iostream> // std::cout
#include <string>
#include <algorithm> // std::clamp

using namespace godot;
using namespace std;

void Model::_register_methods()
{
	register_method("resize", &Model::resize);
	register_method("growAll", &Model::growAll);
	register_method("flowAll", &Model::flowAll);
	register_method("getState", &Model::getState);
	register_method("setState", &Model::setState);
	register_method("setCell", &Model::setCell);
	register_method("getCell", &Model::getCell);
	register_property<Model, int>("width", &Model::width, 40);
	register_property<Model, int>("height", &Model::height, 40);
	// register_property<Model, Grid>("next_state", &Model::next_state, Grid::_new());
	register_property<Model, float>("speed", &Model::speed, 1);
}

Model::Model()
{
}

Model::~Model()
{
	delete last_state;
	delete next_state;
}

RULES Spruce;
RULES Birch;
FIRE Fire;
WATER Water;

void Model::_init()
{
	speed = 1;
	width = 40;
	height = 40;

	Spruce.waterToSprout = .3;
	Spruce.waterToGrow = .15;
	Spruce.portionTaken = .1;
	Spruce.spreadMin = .4;
	Spruce.growRate = .06;
	Spruce.burnRate = .4;

	Birch.waterToSprout = .3;
	Birch.waterToGrow = .3;
	Birch.portionTaken = .1;
	Birch.spreadMin = .06;
	Birch.growRate = .12;
	Birch.burnRate = .4;
}

void Model::resize(int width, int height)
{
	// They need to be defined like this to be passed to GDScript correctly.
	last_state = Grid::_new();
	next_state = Grid::_new();
	last_state->setup(width, height);
	next_state->setup(width, height);
}



void Model::growCell(int x, int y, float speed)
{

	Cell *me = last_state->getCell(x, y);
	Cell *next_me = next_state->getCell(x, y);
	(*next_me).imitate(*me); 	// Next me is already the right cell, so we don't need to set.
	Cell *n[8];
	// TODO: should these return pointers or values?
	n[0] = last_state->getLooping(x, y + 1);
	n[1] = last_state->getLooping(x, y - 1);
	n[2] = last_state->getLooping(x + 1, y);
	n[3] = last_state->getLooping(x - 1, y);
	n[4] = last_state->getLooping(x + 1, y + 1);
	n[5] = last_state->getLooping(x - 1, y - 1);
	n[6] = last_state->getLooping(x + 1, y - 1);
	n[7] = last_state->getLooping(x - 1, y + 1);
	// n is an array of pointers
	// this hella brittle, be careful!
	double spruce = 0;
	double birch = 0;
	double farm = 0;
	double fire = 0;
	for (int i = 0; i < 8; ++i)
	{
		// Cell n = *n[i];
		if (n[i]->on_fire)
			fire += n[i]->height / 4;
		else if (n[i]->species == 1)
			spruce += n[i]->height / 4;
		else if (n[i]->species == 2)
			birch += n[i]->height / 4;
		else if (n[i]->species == 1)
			farm += n[i]->height / 4;
	}
	if (me->isEmpty() && fire < Fire.spreadMin)
	{
		if (birch > Birch.spreadMin && me->water > Birch.waterToSprout)
			(*next_me).species = 2;
		else if (spruce > Spruce.spreadMin && me->water > Spruce.waterToSprout)
			(*next_me).species = 1;
	}
	RULES species;
	if (me->species == 1)
	{
		species = Spruce;
	}
	else if (me->species == 2)
	{
		species = Birch;
	}
	if ((*next_me).species != 0)
	{
		if (me->isATree() && fire > Fire.spreadMin * me->height)
		{
			(*next_me).water -= Fire.dryAmount;
			if ((*next_me).water <= species.waterToLive)
				(*next_me).on_fire = true;
		}
		(*next_me).grow(species, speed);
	}
}

void Model::flowCell(int x, int y, float rain)
{
	Cell *me = last_state->getCell(x, y);
	Cell *next_me = next_state->getCell(x, y);
	(*next_me).imitate(*me); 	// Next me is already the right cell, so we don't need to set.
	Cell *n[4];
	n[0] = last_state->getLooping(x, y + 1);
	n[1] = last_state->getLooping(x, y - 1);
	n[2] = last_state->getLooping(x + 1, y);
	n[3] = last_state->getLooping(x - 1, y);

	float totalWater = me->water;
	float totalFlow = 0;
	for (int i = 0; i < 4; ++i)
	{
		totalWater += n[i]->water;
		float slope = std::clamp((n[i]->elevation - me->elevation) * Water.runoff, -1.0f, 1.0f);
		if (slope > 0)
		{
			totalFlow += n[i]->water * slope;
		}
		else
		{
			totalFlow += me->water * slope;
		}
	}
	double flatWater = totalWater / 5;
	(*next_me).water = flatWater + totalFlow / 4 + rain;
}

void Model::swapStates()
{
	Grid *saved_state = last_state;
	last_state = next_state;
	next_state = saved_state;
	// if (next_state == &state1){
	// 	next_state = &state2;
	// 	last_state = &state1;
	// }
	// else {
	// 	next_state = &state1;
	// 	last_state = &state2;
	// }
}

bool Model::flowAll(float rain)
// void Model::flowAll(float rain)
{
	// last_state.imitate(&next_state);
	swapStates();
	for (int i = 0; i < width; ++i)
	{
		for (int j = 0; j < height; ++j)
		{
			// next_state->setCell(i, j, last_state->flow(i, j, rain, Water));
			// // next_state.setCell(i, j, last_state.flow(i, j, rain));
			flowCell(i, j, rain);
			// growCell(i, j, speed);
		}
	}
	return true;
}

bool Model::growAll()
{
	swapStates();
	for (int i = 0; i < width; ++i)
	{
		for (int j = 0; j < height; ++j)
		{
			growCell(i, j, speed);
		}
	}
	return true;
}

Grid *Model::getState()
// Ref<Grid> Model::getState()
{
	return next_state;
}

void Model::setState(Grid *val)
{
	*next_state = *val;
}

void Model::setCell(int x, int y, Cell *val)
{
	(*next_state).setCell(x, y, val);
}

Cell* Model::getCell(int x, int y)
{
	return (*next_state).getCell(x, y);
}