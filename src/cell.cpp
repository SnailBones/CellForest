#include "cell.h"
#include "rules.h"

#include <iostream> // std::cout
#include <string>
#include <algorithm> // std::min

using namespace godot;
using namespace std;

void Cell::_register_methods()
{
	// register_method("_process", &Cell::_process);
	register_method("isEmpty", &Cell::isEmpty);
	register_method("isATree", &Cell::isATree);
	register_method("die", &Cell::die);
	register_method("grow", &Cell::growD);
	register_property<Cell, int>("species", &Cell::species, 0);
	register_property<Cell, float>("height", &Cell::height, 0);
	register_property<Cell, float>("elevation", &Cell::elevation, 0);
	register_property<Cell, float>("water", &Cell::water, 0);
	register_property<Cell, float>("sediment", &Cell::sediment, 0);
	register_property<Cell, bool>("on_fire", &Cell::on_fire, false);
	register_property<Cell, float>("stress", &Cell::stress, 0);

	register_property<Cell, float>("amplitude", &Cell::amplitude, 10.0);
	register_property<Cell, float>("speed", &Cell::speed, 1.0);
}

Cell::Cell()
{
}

Cell::~Cell()
{
	// add your cleanup here
}

void Cell::_init()
{
	// has to exist
	time_passed = 0.0;
	amplitude = 10.0;
	speed = 1.0;

	height = 0.1f;
	water = .01f;
	// water = .5f;
	sediment = 0.0f;
	on_fire = false;
	elevation = 0.0f;
	stress = 0.0f;

	species = 0;
}

void Cell::imitate(Cell cell)
{

	height = cell.height;
	water = cell.water;
	sediment = cell.sediment;
	on_fire = cell.on_fire;
	elevation = cell.elevation;
	stress = cell.stress;
	species = cell.species;
}

// void Cell::_process(float delta)
// {
// 	time_passed += speed * delta;

// 	Vector2 new_position = Vector2(
// 		amplitude + (amplitude * sin(time_passed * 2.0f)),
// 		amplitude + (amplitude * cos(time_passed * 1.5f)));
// 	// Vector2 new_position = Vector2(100, 100);
// 	set_position(new_position);
// }

bool Cell::isEmpty()
{
	return species == 0;
}

bool Cell::isATree()
{
	return (species == 1 | species == 2);
}

// Rules for species, growSpeed is a global constant.
void Cell::growD(Dictionary d, float growSpeed)
{
	RULES r;
	r.burnRate = d["burnRate"];
	r.waterToLive = d["waterToLive"];
	r.portionTaken = d["portionTaken"];
	r.growRate = d["growRate"];
	// r.burnRate = d["burnRate"];
	r.waterToGrow = d["waterToGrow"];
	grow(r, growSpeed);
}
void Cell::grow(RULES r, float growSpeed)
{
	// TODO: Call function to get rules from species
	if (on_fire)
	{
		height -= r.burnRate;
		if (height <= 0)
		{
			die();
			return;
		}
	}
	else
	//handle farms here if need be, port over farm function
	{
		// stress = 1 - r.waterToLive - water;
		if (water < r.waterToLive)
		{
			die();
			return;
		}
		water -= height * r.waterToLive * r.portionTaken;

		if (water >= r.waterToGrow)
		{
			// float gAmount = std::min(water - r.waterToGrow, r.growRate) * growSpeed;
			// only grow with excess water
			float gAmount = std::min(water - r.waterToGrow, r.growRate * growSpeed);
			// float gAmount = std::min(water, r.growRate * growSpeed);
			height += gAmount;
			water -= gAmount * r.portionTaken;
		}
		// this doesn't make sense but it looks pretty
		// stress = 1 - r.waterToLive - water;
	}
}

void print(String prefix, float val)
{
	String o = prefix + String(std::to_string(val).c_str());
	Godot::print(o);
}

void Cell::die()
{
	// print("HEIGHT is", height);
	species = 0;
	height = 0.0f;
	stress = 0.0f;
	on_fire = false;
	// Godot::print("im ded X.X");
	// print("HEIGHT is", height);
	// converts string to a const char*
}