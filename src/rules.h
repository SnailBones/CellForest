#ifndef RULES_H
#define RULES_H

struct FIRE
{
    float spreadMin = .2;
    // "extinguishChance" : .00,
    float dryAmount = .3;
};
struct WATER
{
    // most of these aren't implemented and do nothing
    float drySeason = .005;
    float wetSeason = .015;
    float seasonLength = 24;
    float evaporation = .01;
    // float diffusion = 2;
    float runoff = 1;
    float erosion = .05;
    float suspended = .2;
};
struct RULES
{
    float burnRate = .4;
    float waterToLive = .15;
    float portionTaken = .2;
    // float grow;
    float growRate;
    float waterToGrow;
    float waterToSprout = .3;
    float spreadMin;
    // float portionTaken;
};

#endif