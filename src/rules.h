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
    // float drySeason = .005;
    // float wetSeason = .015;
    // float seasonLength = 24;
    float evaporation = .01;
    float diffusion = 1;
    float runoff = 1;
    float erosion = .05;
    float suspended = .2;
};
struct RULES
{
    float burnRate;
    float waterToLive;
    float portionTaken;
    float growRate;
    float waterToGrow;
    float waterToSprout;
    float spreadMin;
};

#endif