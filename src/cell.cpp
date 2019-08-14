#include "cell.h"
#include "rules.h"

#include <iostream> // std::cout
#include <string>
#include <algorithm> // std::min

using namespace godot;
using namespace std;

void Cell::_register_methods()
{
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

}

Cell::Cell()
{
}

Cell::~Cell()
{
}

// has to exist
void Cell::_init()
{
	height = 0.0f;
	water = 0.0f;
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
		if (water < r.waterToLive)
		{
			die();
			return;
		}
		water -= height * r.waterToLive * r.portionTaken;

		if (water >= r.waterToGrow)
		{
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
	species = 0;
	height = 0.0f;
	stress = 0.0f;
	on_fire = false;
	// Godot::print("im ded X.X");
}