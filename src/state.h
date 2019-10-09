// A snapshot of global change used to play sounds

#ifndef GLOBAL_H
#define GLOBAL_H

struct oneEar
{
    double die = 0;
    double light = 0;
    double sprout = 0;
    double grow = 0;
};

struct TreeState
{
    oneEar left;
    oneEar right;
};

struct State
{
    struct TreeState birch;
    struct TreeState spruce;
    // double birchDead = 0;
    // double spruceDead = 0;
    // double birchLit = 0;
    // double spruceLit = 0;
    // double birchSprout = 0;
    // double spruceSprout = 0;
    // double birchGrow = 0;
    // double spruceGrow = 0;
};

#endif