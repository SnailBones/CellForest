#ifndef RULES_H
#define RULES_H

struct FIRE
{
    float spreadMin;
    // "extinguishChance" : .00,
    float dryAmount;
};
struct WATER
{
    // float drySeason = .005;
    // float wetSeason = .015;
    // float seasonLength = 24;
    float evaporation;
    float diffusion;
    float runoff;
    float erosion;
    float suspended;
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