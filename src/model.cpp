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
}

// RULES spruce;
// RULES birch;
// FIRE fire;
// WATER water;

void Model::_init()
{
	speed = 1;
	width = 40;
	height = 40;

	// spruce.waterToSprout = .3;
	// spruce.waterToGrow = .15;
	// spruce.portionTaken = .1;
	// spruce.spreadMin = .4;
	// spruce.growRate = .06;
	// spruce.burnRate = .4;

	// birch.waterToSprout = .3;
	// birch.waterToGrow = .3;
	// birch.portionTaken = .1;
	// birch.spreadMin = .06;
	// birch.growRate = .12;
	// birch.burnRate = .4;

	cout << "About to make my favorite states\n";

	last_state.init(width, height);
	cout << "Made last state\n";
	next_state.init(width, height);
	cout << "Made next state\n";
}

void Model::resize(int width, int height)
{
	last_state.init(width, height);
	next_state.init(width, height);
}

void Model::growAll()
{
	// last_state = next_state;
	Cell c = *next_state.getCell(39, 39);
	cout
		<< "in growAll()! \n";
	cout << "width is" << next_state.width << "\n";
	cout << "height is" << next_state.height << "\n";
	cout << "cell .species is" << c.species << "\n";
	cout << "cell .height is" << c.height << "\n";
	cout << "cell .elevation is" << c.elevation << "\n";
	cout << "cell .water is" << c.water << "\n";
	cout << "growing, about to imitate\n";
	last_state.imitate(next_state);
	cout << "setting cells in new state \n";
	// or is there a clever way to switch them?
	for (int i = 0; i < width; ++i)
	{
		for (int j = 0; j < height; ++j)
		{
			cout << "cell" << i << " " << j << "\n";
			// Cell *cell = last_state.grow(i, j, speed, spruce, birch, fire);
			Cell *cell = Cell::_new();
			// (*nextMe)._init();
			// cout << "next me initialized! height is" << (*nextMe).height << "\n";
			// (*cell).imitate(*last_state.grow(i, j, speed, spruce, birch, fire)); // copy
			// (*cell).imitate(*last_state.grow(i, j, speed)); // copy
			// cout << "grew cell!\n";
			// cout << "cell .height is" << cell->height << "\n";
			// cout << "cell .species is" << cell->species << "\n";
			// cout << "cell .elevation is" << cell->elevation << "\n";
			// cout << "cell .elevation is" << (*cell).elevation << "\n";
			// cout << "cell .water is" << cell->water << "\n";
			// next_state.setCell(i, j, cell);
			// cout << "set cell! now deleting \n ";
			// delete cell;
			// cout << "delete success \n ";
		}
	}
	cout << "cells grown \n";
}
void Model::flowAll(float rain)
{
	last_state.imitate(next_state);
	for (int i = 0; i < width; ++i)
	{
		for (int j = 0; j < height; ++j)
		{
			// next_state.setCell(i, j, last_state.flow(i, j, rain, water));
			// next_state.setCell(i, j, last_state.flow(i, j, rain));
		}
	}
}

Grid *Model::getState()
// Ref<Grid> Model::getState()
{
	// Grid *v = &next_state;

	Grid *v = Grid::_new();
	// *v = next_state; // Copy
	(*v).imitate(next_state); // copy
	// (*v).init(width, height);
	// I dunno why but this is the only way ( i know ) of how you can do this without breaking everything
	// return v;
	// Cell c = *v;
	// float height = c.height;
	Cell c = *(*v).getCell(39, 39);
	cout
		<< "in getState()! \n";
	cout << "width is" << (*v).width << "\n";
	cout << "height is" << (*v).height << "\n";
	cout << "cell .species is" << c.species << "\n";
	cout << "cell .height is" << c.height << "\n";
	cout << "cell .elevation is" << c.elevation << "\n";
	cout << "cell .water is" << c.water << "\n";
	cout << "about to ref \n";
	// // Ref<Grid> vr = Ref<Grid>(v);
	// Ref<Grid> vr = Ref<Grid>(Grid::_new());
	cout << "reffing state\n!";
	return v;
	// return vr;
}

void Model::setState(Grid *val)
{
	next_state = *val;
}

void Model::setCell(int x, int y, Cell *val)
{
	next_state.setCell(x, y, val);
}