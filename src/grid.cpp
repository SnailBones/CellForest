#include "grid.h"
// #include "rules.h"

#include <iostream> // std::cout
#include <string>
#include <algorithm> // std::clamp
#include <assert.h>  /* assert */

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
	// register_method("grow", &Grid::grow);
	// register_method("flow", &Grid::flow);
	register_method("imitate", &Grid::imitate);
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

// RULES SpruceRules;
// RULES BirchRules;
// FIRE FireRules;
// WATER water;

void Grid::_init()
{

}

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
			grid[x][y]->sediment = .5f;
			grid[x][y]->species = 0;
			grid[x][y]->water = .1f;
			// 	// Cell *nCell = Cell::_new();
			// 	// grid[x][y] = *nCell;
			// 	// setCell(i, j, other.getCell(i, j));
		}
	}
}

void Grid::imitate(Grid *other) // Presumes I'm is already initialized and with correct width/height, copies values
{
	// cout << "imitatitng in Grid! \n";
	// width = other->width;
	// height = other->height;
	// grid = new Cell **[width];
	for (int i = 0; i < width; ++i)
	{
		// grid[i] = new Cell *[height];
		for (int j = 0; j < height; ++j)
		{
			// cout << "setting cell\n";
			// setCell(i, j, other.getCell(i, j));
			// delete grid[i][j]; // Free up previous memory
			// grid[i][j] = Cell::_new(); // crashes without this
			Cell o_cell = *(other->getCell(i, j));
			// *grid[i][j].imitate(o_cell);
			grid[i][j]->imitate(o_cell);
			// grid[x][y]->sediment = .5f;
			// grid[x][y]->species = 0;
			// grid[x][y]->water = .1f;
			// 	// Cell *nCell = Cell::_new
		}
	}
}

void Grid::setCell(int x, int y, Cell *val)
{
	assert(x < width);
	assert(y < height);

	// *grid[x][y] = *val; // Copying value
	grid[x][y] = val; // Copying pointer, value is wherever it was made.
}

Cell *Grid::getCell(int x, int y)
{
	assert(x < width);
	assert(y < height);
	// Cell *v = &(grid[x][y]); // Return pointer within array
	return grid[x][y]; // Return pointer at value in arary
	// return v;
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
	assert(x < width);
	assert(y < height);
	Cell v = *grid[x][y];
	// cout << " THE LORAX QUOTH: cell is " << x << " " << y << "\n";
	// cout << " * height is " << v.height << "\n";
	// cout << " * species is " << v.species << "\n";
	// cout << " * elevation is " << v.elevation << "\n";
	// cout << " * sediment is " << v.sediment << "\n";
	// cout << " * water is " << v.water << "\n";
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
	// return getCell((x + width) % width, (y + height) % height);
	return getCell((x % width + width) % width, (y % height + height) % height);
}