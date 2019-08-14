#include "model.h"
// #include "rules.h"

#include <iostream> // std::cout
#include <string>
#include <algorithm> // std::clamp, std:min
#include <assert.h>  /* assert */

using namespace godot;
using namespace std;

void Model::_register_methods()
{
	register_method("setup", &Model::setup);
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
	// They need to be defined like this to be passed to GDScript correctly.
	last_state = Grid::_new();
	next_state = Grid::_new();
}

void Model::setup(int w, int h, float s, Dictionary spruce, Dictionary birch, Dictionary water, Dictionary fire)
{
	width = w;
	height = h;
	speed = s;
	last_state->setup(width, height);
	next_state->setup(width, height);
	
	Spruce.waterToLive = spruce["waterToLive"];
	Spruce.waterToSprout = spruce["waterToSprout"];
	Spruce.waterToGrow = spruce["waterToGrow"];
	Spruce.portionTaken = spruce["portionTaken"];
	Spruce.spreadMin = spruce["spreadMin"];
	Spruce.growRate = spruce["growRate"];
	Spruce.burnRate = spruce["burnRate"];

	Birch.waterToLive = birch["waterToLive"];
	Birch.waterToSprout = birch["waterToSprout"];
	Birch.waterToGrow = birch["waterToGrow"];
	Birch.portionTaken = birch["portionTaken"];
	Birch.spreadMin = birch["spreadMin"];
	Birch.growRate = birch["growRate"];
	Birch.burnRate = birch["burnRate"];


	Water.evaporation = water["evaporation"];
	Water.diffusion = water["diffusion"];
	Water.runoff = water["runoff"];
	Water.erosion = water["erosion"];
	Water.suspended = water["suspended"];

	Fire.spreadMin = fire["spreadMin"];
	Fire.dryAmount = fire["dryAmount"];

	cout << "Spruce.waterToSprout is " << Spruce.waterToSprout << "\n";
	cout << "Spruce.waterToGrow is " << Spruce.waterToGrow << "\n";
	cout << "Spruce.portionTaken is " << Spruce.portionTaken << "\n";
	cout << "Spruce.growRate is " << Spruce.growRate << "\n";
	cout << "Spruce.spreadMin is " << Spruce.spreadMin << "\n";
	cout << "Spruce.waterToLive is " << Spruce.waterToLive << "\n";

	cout << "Birch.waterToSprout is " << Birch.waterToSprout << "\n";
	cout << "Birch.waterToGrow is " << Birch.waterToGrow << "\n";
	cout << "Birch.portionTaken is " << Birch.portionTaken << "\n";
	cout << "Birch.growRate is " << Birch.growRate << "\n";
	cout << "Birch.spreadMin is " << Birch.spreadMin << "\n";
	cout << "Birch.waterToLive is " << Birch.waterToLive << "\n";

	cout << "Water.diffusion is " << Water.diffusion << "\n";
	cout << "Water.evaporation is " << Water.evaporation << "\n";

	cout << "all set up! \n";

	assert(Water.diffusion <= 1);
	assert(Water.evaporation < 1);

	
}



void Model::growCell(int x, int y, float speed)
{

	Cell *me = last_state->getCell(x, y);
	Cell *next_me = next_state->getCell(x, y);
	(*next_me).imitate(*me); 	// Next me is already the right cell, so we don't need to set.
	Cell *n[8];
	n[0] = last_state->getLooping(x, y + 1);
	n[1] = last_state->getLooping(x, y - 1);
	n[2] = last_state->getLooping(x + 1, y);
	n[3] = last_state->getLooping(x - 1, y);
	n[4] = last_state->getLooping(x + 1, y + 1);
	n[5] = last_state->getLooping(x - 1, y - 1);
	n[6] = last_state->getLooping(x + 1, y - 1);
	n[7] = last_state->getLooping(x - 1, y + 1);
	double spruce = 0, birch = 0;
	double farm = 0;
	double fire = 0;
	for (int i = 0; i < 8; ++i)
	{
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
		{
			(*next_me).species = 2;
		}
		if (spruce > Spruce.spreadMin && me->water > Spruce.waterToSprout)
		{
			(*next_me).species = 1;
		}
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
	float water_force = 0;
	float sediment_in = 0;
	float sediment_out = 0;
	for (int i = 0; i < 4; ++i)
	{
		totalWater += n[i]->water;
		float slope = std::clamp((n[i]->elevation - me->elevation) * Water.runoff, -1.0f, 1.0f);
		if (slope > 0)
		{
			float amt = n[i]->water * slope;
			totalFlow += amt;
			water_force += amt;
			sediment_in += n[i]->sediment * amt;
		}
		else
		{
			float amt = me->water * slope;
			totalFlow += amt;
			// Let's try half erosion for water draining away
			water_force -= amt;
			// This could be optimized
			sediment_out -= me->sediment * amt;

		}
	}
	float all_diffusion = totalWater / 5;
	float diffuse_change = Water.diffusion*(all_diffusion-me->water);
	// Balancing between flow and diffusion, this ensures we don't
	// change the water too much in one step and create weird bugs.
	float flow_change = (1-Water.diffusion)*(totalFlow/4);
	float water = me->water + diffuse_change + flow_change + rain;
	if (water > 1)
		water -= Water.evaporation;
	next_me->water = water;

	float sed_change = (sediment_in-sediment_out)/4;
	next_me->sediment += sed_change;

	// Erosion is speed * water amount
	float erode = Water.erosion * water_force/4;
	// float sediment;
	// next_me-> elevation -= erode;
	next_me->sediment += erode;


	// Maximum sediment is based on speed, anything over that is deposited
	float max_sediment = water_force * Water.suspended;
	if (next_me->sediment > max_sediment){
		float deposit = min(next_me->sediment-max_sediment, 1.0f);
		// next_me->elevation +=deposit;
		next_me->sediment -= deposit;
		// next_me->elevation += next_me->sediment-max_sediment;
		// next_me->sediment = max_sediment;
	}
}

void Model::swapStates()
{
	Grid *saved_state = last_state;
	last_state = next_state;
	next_state = saved_state;
}

// bool Model::flowAll(float rain)
void Model::flowAll(float rain)
{
	swapStates();
	for (int i = 0; i < width; ++i)
	{
		for (int j = 0; j < height; ++j)
		{
			flowCell(i, j, rain);
			// growCell(i, j, speed);
		}
	}
}

void Model::growAll()
{
	swapStates();
	for (int i = 0; i < width; ++i)
	{
		for (int j = 0; j < height; ++j)
		{
			growCell(i, j, speed);
		}
	}
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