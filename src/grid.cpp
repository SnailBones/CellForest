#include "grid.h"
// #include "rules.h"

#include <iostream> // std::cout
#include <string>
#include <algorithm> // std::clamp

using namespace godot;
using namespace std;

void Grid::_register_methods()
{
	// register_method("init", &Grid::init);
	register_method("setup", &Grid::setup);
	// register_method("getCell", &Grid::getCellRef);
	register_method("getCell", &Grid::getCell);
	register_method("getLooping", &Grid::getLooping);
	register_method("setCell", &Grid::setCell);
	register_method("lorax", &Grid::lorax);
	register_method("G", &Grid::G);
	register_method("S", &Grid::S);
	register_property<Grid, int>("width", &Grid::width, 40);
	register_property<Grid, int>("height", &Grid::height, 40);
	register_method("grow", &Grid::grow);
	register_method("flow", &Grid::flow);
}

Grid::Grid()
{
}

Grid::~Grid()
{
	// add your cleanup here
	for (int i = 0; i < width; ++i)
		delete[] grid[i];
	delete[] grid;
}

RULES SpruceRules;
RULES BirchRules;
FIRE FireRules;
WATER water;

void Grid::_init()
{
	// speed = 1;

	SpruceRules.waterToSprout = .3;
	SpruceRules.waterToGrow = .15;
	SpruceRules.portionTaken = .1;
	SpruceRules.spreadMin = .4;
	SpruceRules.growRate = .06;
	SpruceRules.burnRate = .4;

	BirchRules.waterToSprout = .3;
	BirchRules.waterToGrow = .3;
	BirchRules.portionTaken = .1;
	BirchRules.spreadMin = .06;
	BirchRules.growRate = .12;
	BirchRules.burnRate = .4;
}
// Node Grid::init(int w, int h)
// {
// 	// has to exist
// 	width = w;
// 	height = h;
// 	grid = new Cell *[width];
// 	for (int i = 0; i < width; ++i)
// 		grid[i] = new Cell[height];
// 	return Node(*this);
// }
void Grid::init(int w, int h)
{
	width = w;
	height = h;
	grid = new Cell **[width];
	for (int i = 0; i < width; ++i)
		// grid[i] = new Cell[height];
		grid[i] = new Cell *[height]();
	// setup();
}

// Setup here because scope change dosen't preserve cell values
// I.E. cells cannot be initialized in a loop
void Grid::setup(int w, int h)
{
	width = w;
	height = h;
	grid = new Cell **[width];
	for (int x = 0; x < width; ++x)
	{
		grid[x] = new Cell *[height];
		for (int y = 0; y < height; ++y)
		{
			grid[x][y] = Cell::_new();
			grid[x][y]->_init();
			grid[x][y]->sediment = .5;
			grid[x][y]->species = 1;
			grid[x][y]->water = .5;
			// 	// Cell *nCell = Cell::_new();
			// 	// grid[x][y] = *nCell;
			// 	// setCell(i, j, other.getCell(i, j));
		}
	}
}

void Grid::imitate(Grid other)
{
	width = other.width;
	height = other.height;
	grid = new Cell **[width];
	for (int i = 0; i < width; ++i)
	{
		grid[i] = new Cell *[height];
		for (int j = 0; j < height; ++j)
			setCell(i, j, other.getCell(i, j));
	}
}

void Grid::setCell(int x, int y, Cell *val)
{
	// *grid[x][y] = *val; // Copying value
	grid[x][y] = val; // Copying pointer, value is wherever it was made.
}

Cell *Grid::getCell(int x, int y)
{
	// Cell *v = &(grid[x][y]); // Return pointer within array
	Cell *v = grid[x][y]; // Return pointer at value in arary
	return v;
}

// void Grid::setCellRef(int x, int y, Ref<Cell> val)
// {

// }

void print(String prefix, Ref<Cell> val)
{
	// String o = prefix + String(std::to_string(val).c_str());
	// Godot::print(o, val);
}

Ref<Cell> Grid::getCellRef(int x, int y)
{
	Cell *c = getCell(x, y);
	// Cell *c = &(grid[x][y]);
	// Cell c = *v;
	Ref<Cell> r = Ref<Cell>(c);
	// cout << "Cell " << x << " " << y << " height is: " << v->height << "\n";
	// cout << "Returning getCellRef in C++ \n";
	return r;
}

void Grid::lorax(int x, int y)
{
	Cell v = *grid[x][y];
	cout << " THE LORAX QUOTH: cell is " << x << " " << y << "\n";
	cout << " * height is " << v.height << "\n";
	cout << " * species is " << v.species << "\n";
	cout << " * elevation is " << v.elevation << "\n";
	cout << " * sediment is " << v.sediment << "\n";
	cout << " * water is " << v.water << "\n";
	return;
}

Ref<Cell> Grid::G(godot::Array a)
{
	int x = a[0];
	int y = a[1];
	// cout << "in G! x is " << x << " y is " << y << "\n";
	// Cell *v = &(grid[x][y]);
	// return v;
	return getCellRef(x, y);
}

void Grid::S(Array a, Cell *val)
{
	int x = a[0];
	int y = a[1];
	setCell(x, y, val);
}

Cell *Grid::getLooping(int x, int y)
{
	return getCell((x + width) % width, (y + height) % height);
}

// Cell **Grid::getNeighbors(int x, int y)
// {
// 	Cell *neighbors[4];
// 	// TODO: should these return pointers or values?
// 	// it's returning a temporary value, fix this
// 	neighbors[0] = getLooping(x, y + 1);
// 	neighbors[1] = getLooping(x, y - 1);
// 	neighbors[2] = getLooping(x + 1, y);
// 	neighbors[3] = getLooping(x - 1, y);
// 	return neighbors;
// }

// Cell *Grid::getMoreNeighbors(int x, int y)
// {
// 	Cell neighbors[8];
// 	neighbors[0] = *getLooping(x, y + 1);
// 	neighbors[1] = *getLooping(x, y - 1);
// 	neighbors[2] = *getLooping(x + 1, y);
// 	neighbors[3] = *getLooping(x - 1, y);
// 	neighbors[4] = *getLooping(x + 1, y + 1);
// 	neighbors[5] = *getLooping(x - 1, y - 1);
// 	neighbors[6] = *getLooping(x + 1, y - 1);
// 	neighbors[7] = *getLooping(x - 1, y + 1);
// 	return neighbors;
// }

// Cell **Grid::getMoreNeighbors(int x, int y)
// {
// 	Cell *neighbors[8];
// 	// TODO: should these return pointers or values?
// 	neighbors[0] = getLooping(x, y + 1);
// 	neighbors[1] = getLooping(x, y - 1);
// 	neighbors[2] = getLooping(x + 1, y);
// 	neighbors[3] = getLooping(x - 1, y);
// 	neighbors[4] = getLooping(x + 1, y + 1);
// 	neighbors[5] = getLooping(x - 1, y - 1);
// 	neighbors[6] = getLooping(x + 1, y - 1);
// 	neighbors[7] = getLooping(x - 1, y + 1);
// 	return neighbors;
// }

// Cell *Grid::grow(int x, int y, float speed, RULES SpruceRules, RULES BirchRules, FIRE FireRules)
// Cell *Grid::grow(int x, int y, float speed)
Ref<Cell> Grid::grow(int x, int y, float speed)
{
	Cell me = *(getCell(x, y));
	// new is not supported, yuck. neither seems ot be the =.
	Cell *nextMe = Cell::_new();
	// (*nextMe)._init();
	// cout << "next me initialized! height is" << (*nextMe).height << "\n";
	(*nextMe).imitate(me); // copy
	// cout << "next me height changed to" << (*nextMe).height << "\n";
	// Cell nextMe = *nextPtr;
	// IMPORTANT: nextMe needs to be in the heap. GDScript cannot access the stack.
	// nextMe.height += .1;
	// cout << "Initial height is" << me.height << "\n";
	// cout << "Copy height is" << nextMe.height << "\n";
	// Cell **neighbors = getMoreNeighbors(x, y);
	Cell *neighbors[8];
	// TODO: should these return pointers or values?
	neighbors[0] = getLooping(x, y + 1);
	neighbors[1] = getLooping(x, y - 1);
	neighbors[2] = getLooping(x + 1, y);
	neighbors[3] = getLooping(x - 1, y);
	neighbors[4] = getLooping(x + 1, y + 1);
	neighbors[5] = getLooping(x - 1, y - 1);
	neighbors[6] = getLooping(x + 1, y - 1);
	neighbors[7] = getLooping(x - 1, y + 1);
	// Neighbors is an array of pointers
	// this hella brittle, be careful!
	double spruce = 0;
	double birch = 0;
	double farm = 0;
	double fire = 0;
	for (int i = 0; i < 8; ++i)
	{
		Cell n = *neighbors[i];
		if (n.on_fire)
			fire += n.height / 4;
		else if (n.species == 1)
			spruce += n.height / 4;
		else if (n.species == 2)
			birch += n.height / 4;
		else if (n.species == 1)
			farm += n.height / 4;
	}
	if (me.isEmpty() && fire < FireRules.spreadMin)
	{
		if (birch > BirchRules.spreadMin && me.water > BirchRules.waterToSprout)
			(*nextMe).species = 2;
		else if (spruce > SpruceRules.spreadMin && me.water > SpruceRules.waterToSprout)
			(*nextMe).species = 1;
	}
	RULES species;
	if (me.species == 1)
	{
		species = SpruceRules;
	}
	else if (me.species == 2)
	{
		species = BirchRules;
	}
	if ((*nextMe).species != 0)
	{
		if (me.isATree() && fire > FireRules.spreadMin * me.height)
		{
			(*nextMe).water -= FireRules.dryAmount;
			if ((*nextMe).water <= species.waterToLive)
				(*nextMe).on_fire = true;
		}
		(*nextMe).grow(species, speed);
	}
	// if (x == 4 && y == 4)
	// {
	// 	cout << "Last water is" << me.water << "\n";
	// 	cout << "Next water is" << (*nextMe).water << "\n";
	// 	// cout << "Next species is" << (*nextMe).species << "\n";
	// 	// cout << "Next on_fire is" << *nextPtr.on_fire << "\n";
	// 	// cout << "Next elevation is" << (*nextPtr).elevation << "\n";
	// }
	// return &nextMe;
	// Cell c = *v;
	// float height = c.height;
	Ref<Cell> vr = Ref<Cell>(nextMe);
	return vr;
	// return nextMe;
	// Find documentation on Ref and its advantages over a pointer.
}

Ref<Cell> Grid::flow(int x, int y, float rain)
// Cell *Grid::flow(int x, int y, float rain, WATER water)
// Cell *Grid::flow(int x, int y, float rain)
{
	Cell me = *(getCell(x, y));
	Cell *nextMe = Cell::_new();
	(*nextMe).imitate(me); // copy
	Cell *neighbors[4];
	// TODO: should these return pointers or values?
	neighbors[0] = getLooping(x, y + 1);
	neighbors[1] = getLooping(x, y - 1);
	neighbors[2] = getLooping(x + 1, y);
	neighbors[3] = getLooping(x - 1, y);

	float totalWater = me.water;
	float totalFlow = 0;
	for (int i = 0; i < 4; ++i)
	{
		Cell n = *neighbors[i];
		totalWater += n.water;
		float slope = std::clamp((n.elevation - me.elevation) * water.runoff, -1.0f, 1.0f);
		if (slope > 0)
		{
			totalFlow += n.water * slope;
		}
		else
		{
			totalFlow += me.water * slope;
		}
	}
	double flatWater = totalWater / 5;
	(*nextMe).water = flatWater + totalFlow / 4 + rain;

	// if (x == 0 && y == 0)
	// {
	// 	cout << "\ntotalFlow is" << totalFlow << "\n";
	// 	cout << "totalWater is" << totalWater << "\n";
	// 	cout << "rain is" << rain << "\n";
	// 	cout << "initial water is" << me.water << "\n";
	// 	cout << "final water is" << (*nextMe).water << "\n";
	// }

	Ref<Cell> vr = Ref<Cell>(nextMe);
	return vr;
	// return nextMe;
}