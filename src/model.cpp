#include "model.h"

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

// State st;

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

	// cout << "Spruce.waterToSprout is " << Spruce.waterToSprout << "\n";
	// cout << "Spruce.waterToGrow is " << Spruce.waterToGrow << "\n";
	// cout << "Spruce.portionTaken is " << Spruce.portionTaken << "\n";
	// cout << "Spruce.growRate is " << Spruce.growRate << "\n";
	// cout << "Spruce.spreadMin is " << Spruce.spreadMin << "\n";
	// cout << "Spruce.waterToLive is " << Spruce.waterToLive << "\n";

	// cout << "Birch.waterToSprout is " << Birch.waterToSprout << "\n";
	// cout << "Birch.waterToGrow is " << Birch.waterToGrow << "\n";
	// cout << "Birch.portionTaken is " << Birch.portionTaken << "\n";
	// cout << "Birch.growRate is " << Birch.growRate << "\n";
	// cout << "Birch.spreadMin is " << Birch.spreadMin << "\n";
	// cout << "Birch.waterToLive is " << Birch.waterToLive << "\n";

	// cout << "Water.diffusion is " << Water.diffusion << "\n";
	// cout << "Water.evaporation is " << Water.evaporation << "\n";

	// cout << "all set up! \n";

	assert(Water.diffusion <= 1);
	assert(Water.evaporation < 1);
}

// records its effects to the global state through &st
void Model::growCell(int x, int y, float speed, State &st)
{

	Cell *me = last_state->getCell(x, y);
	Cell *next_me = next_state->getCell(x, y);
	(*next_me).imitate(*me);
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
		// stats = &(st->spruce);
	}
	else if (me->species == 2)
	{
		species = Birch;
		// stats = &(st->birch);
	}
	// cout << "BEGIN!\n";
	// cout << "birch sprout is " << st.birch.sprout << "\n";
	// cout << "spruce sprout is " << st.spruce.sprout << "\n";
	// cout << "birch is at " << &(st.birch) << "\n";
	// cout << "spruce is at " << &(st.spruce) << "\n";
	// cout << "stats points to " << stats << "\n";
	// cout << "sprout is " << stats->sprout << "\n";
	// cout << "grow is " << stats->grow << "\n";
	// cout << "die is " << stats->die << "\n";
	// cout << "light is " << stats->light << "\n";
	// cout << "GROWING!\n";
	float lit = 0;
	float grow = 0;
	if ((*next_me).species != 0)
	{
		float sound_offset = float(x + y) / (width + height - 2);
		//float sound_offset = .5;
		// TODO width + height - 2 ?
		TreeState *stats;
		if (next_me->species == 1)
		{
			stats = &(st.spruce);
			species = Spruce;
		}
		else
		{
			stats = &(st.birch);
			species = Birch;
		}
		if (me->isATree() && fire > Fire.spreadMin * me->height)
		{
			(*next_me).water -= Fire.dryAmount;
			if ((*next_me).water <= species.waterToLive)
			{
				(*next_me).on_fire = true;
				stats->right.light += 1. - sound_offset;
				stats->left.light += sound_offset;
			}
		}
		grow = (*next_me).grow(species, speed);
		// if old is empty and new is a tree, i sprouted.
		if (me->isEmpty())
		{
			// cout << "birch sprout is " << st.birch.sprout << "\n";
			// cout << "spruce sprout is " << st.spruce.sprout << "\n";
			// cout << "sprout is " << stats->sprout << "\n";
			//stats->sprout++;
			stats->right.sprout += 1. - sound_offset;
			stats->left.sprout += sound_offset;
			// cout << "now sprout is " << stats->sprout << "\n";
			// cout << "now birch sprout is " << st.birch.sprout << "\n";
			// cout << "now spruce sprout is " << st.spruce.sprout << "\n";
		}
		else if (grow == -1.f)
		{
			// cout << "die is " << stats->die << "\n";
			stats->right.die += 1. - sound_offset;
			stats->left.die += sound_offset;
			// cout << "after die is " << stats->die << "\n";
		}
		else
		{
			// cout << "grow is " << stats->grow << "\n";
			//stats->grow += grow;
			stats->right.grow += (1. - sound_offset) * grow;
			stats->left.grow += (sound_offset)*grow;
			// cout << "after grow is " << stats->grow << "\n";
			// cout << "now birch grow is " << st.birch.grow << "\n";
			// cout << "now spruce grow is " << st.spruce.grow << "\n";
		}
	}
	// godot::Array outArray;
	// outArray.append(lit);
	// outArray.append(grow);
	// return outArray;
}

// grows all cells and returns changes to be converted to sound
// returns an array including for each species:
// death count
// number lit on fire
// growth amount (excluding sprouts)
// sprout amount

godot::Variant Model::growAll()
{
	State st = State();
	// State *state = new State;
	// State st = *state;

	// cout << "starting to grow!  these should be 0: \n";
	// cout << " spruce die is " << st.spruce.die << "\n";
	// cout << " spruce sprout is " << st.spruce.sprout << "\n";
	// cout << " birch sprout is " << st.birch.sprout << "\n";

	swapStates();
	for (int i = 0; i < width; ++i)
	{
		for (int j = 0; j < height; ++j)
		{
			// cout << "growing:: " << i << " " << j << "\n";
			growCell(i, j, speed, st);
		}
	}
	godot::Array outArray;
	// Converts our custom struct into a GDScript array.
	outArray.append(st.birch.left.die);
	outArray.append(st.spruce.left.die);
	outArray.append(st.birch.left.light);
	outArray.append(st.spruce.left.light);
	outArray.append(st.birch.left.grow);
	outArray.append(st.spruce.left.grow);
	outArray.append(st.birch.left.sprout);
	outArray.append(st.spruce.left.sprout);

	outArray.append(st.birch.right.die);
	outArray.append(st.spruce.right.die);
	outArray.append(st.birch.right.light);
	outArray.append(st.spruce.right.light);
	outArray.append(st.birch.right.grow);
	outArray.append(st.spruce.right.grow);
	outArray.append(st.birch.right.sprout);
	outArray.append(st.spruce.right.sprout);
	return outArray;
}

float waterGiven, waterTaken, dirtGiven, dirtTaken, dirtErode, dirtDeposit;
float totalWater;

void Model::printTotals()
{
	float water = 0;
	float dirt = 0;
	float rock = 0;
	for (int i = 0; i < width; ++i)
	{
		for (int j = 0; j < height; ++j)
		{
			Cell *me = next_state->getCell(i, j);
			water += me->water;
			dirt += me->sediment;
			rock += me->elevation;
		}
	}
	cout << "totals! \n";
	cout << "total water is " << water << "\n";
	cout << "total dirt is" << dirt + rock << "\n";
}

void Model::flowCell(int x, int y, float rain)
{
	// waterGiven = 0;
	// waterTaken = 0;
	// dirtGiven = 0;
	// dirtTaken = 0;
	// dirtErode = 0;
	// dirtDeposit = 0;
	Cell *me = last_state->getCell(x, y);
	Cell *next_me = next_state->getCell(x, y);
	(*next_me).imitate(*me); // Next me is already the right cell, so we don't need to set.
	Cell *n[4];
	n[0] = last_state->getLooping(x, y + 1);
	n[1] = last_state->getLooping(x, y - 1);
	n[2] = last_state->getLooping(x + 1, y);
	n[3] = last_state->getLooping(x - 1, y);

	Cell *next[4];
	next[0] = next_state->getLooping(x, y + 1);
	next[1] = next_state->getLooping(x, y - 1);
	next[2] = next_state->getLooping(x + 1, y);
	next[3] = next_state->getLooping(x - 1, y);

	float totalWater = me->water;
	float totalFlow = 0;
	float water_force = 0;
	float sediment_in = 0;
	float sediment_out = 0;
	float total_sediment = 0;
	float slope_down = 0;
	float slope_up = 0;
	for (int i = 0; i < 4; ++i)
	{
		float sed_move = 0;
		totalWater += n[i]->water;
		float slope = std::clamp((n[i]->elevation - me->elevation) * Water.runoff, -1.0f, 1.0f);
		if (slope > 0) // Other is higher
		{
			float amt = n[i]->water * slope; // portion of 1/4 of water that comes in
			totalFlow += amt;
			water_force += amt;
			// sed_move = n[i]->sediment * amt;
			// sed_move = amt;
			sed_move = std::min(amt * n[i]->sediment, slope);
			sediment_in += sed_move; // portion of sediment that comes with water
			slope_up += slope;
			total_sediment += sed_move;
		}
		else
		{ // Other is lower
			float amt = me->water * slope;
			totalFlow += amt;
			water_force -= amt;
			// This could be optimized
			// sed_move = me->sediment * amt;
			sed_move = std::max(amt * n[i]->sediment, slope);
			// sed_move = amt;
			sediment_out -= sed_move;
			slope_down -= slope;
			total_sediment += sed_move;
		}
		// next[i]->sediment -= sed_move / 8;
		// me->sediment += sed_move / 8;
		// sed_move = slope;
		// next[i]->elevation -= sed_move/2;
		// me-> elevation += sed_move/2;
	}
	float all_diffusion = totalWater / 5;
	float diffuse_change = Water.diffusion * (all_diffusion - me->water);
	// Balancing between flow and diffusion, this ensures we don't
	// change the water too much in one step and create weird bugs.
	float flow_change = (1 - Water.diffusion) * (totalFlow / 4);
	// float flow_change = totalFlow / 4;
	float water = me->water + diffuse_change + flow_change + rain;
	// float water = me->water + flow_change + rain;
	if (water > 1)
		// Too much water in one place leads to weird bugs with sediment.
		water -= (Water.evaporation + rain);
	// water = 1;
	next_me->water = water;

	// float sed_change = (1-Water.diffusion)*(sediment_in-sediment_out)/4;
	// float sed_change = (sediment_in-sediment_out);
	float sed_change = (1 - Water.diffusion) * (total_sediment / 4);
	// float sed_change = sediment_out/4;
	next_me->sediment += sed_change;
	// next_me->elevation = sed_change;
	// next_me->elevation += sed_change;
	// sediment fluctuates wildly in flat areas sometimes. why?

	// Maximum sediment is based on speed, anything over that is deposited
	// We treat speed as slope squared to give slope more weight.
	// Only slope beneath should contribute, otherwise water stays put.
	// float max_sediment = (water_force * Water.suspended;
	// float max_sediment = (slope_up + slope_down + .3) * next_me->water * Water.suspended;
	// float max_sediment = std::max(slope_up, .1f) * std::min(next_me->water, 1.0f) * Water.suspended;
	// float max_sediment = 0;
	// Erosion equation, max sediment is slope * speed * water * constant.
	float max_sediment = slope_down * water_force * Water.suspended;
	// float max_sediment = slope_down * Water.suspended;
	// float deposit = next_me->sediment * .2;
	// float max_sediment = std::min(max_sediment, 10.0f);
	// float max_sediment = (slope_down + .1) * next_me->water * Water.suspended;
	// if (next_me->sediment > max_sediment)
	// We're currently using the same contsant (and equation)
	// for erosion and deposition.
	// A positive deposit is deposition, negative is erosion.
	float deposit = (1 - Water.diffusion) * (me->sediment - max_sediment) * Water.erosion;
	// no eroding wells or depositing towers. This isn't really working.
	deposit = std::clamp(deposit, -slope_down, slope_up);
	next_me->elevation += deposit;
	next_me->sediment -= deposit;
	// Erosion is speed * water amount
	// float erode = Water.erosion * water_force/4;

	// float erode = Water.erosion * abs(totalFlow);
	// only erode when water enters (it has momentum)
	// also this fixes a nasty jitter bug
	// float erode = (slope_up) * (slope_up)*me->water * Water.erosion;
	// // next_me -> sediment += .02;
	// // float erode = .5;
	// // erode = std::min(erode, max_sediment - next_me->sediment);
	// // float erode = min(0.0f, totalFlow) * Water.erosion;
	// // float sediment;
	// next_me->elevation -= erode;
	// next_me->sediment += erode;
	// // next_me->test_var = totalFlow;
	// next_me->test_var = total_sediment;
	next_me->test_var = max_sediment;
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

Cell *Model::getCell(int x, int y)
{
	return (*next_state).getCell(x, y);
}