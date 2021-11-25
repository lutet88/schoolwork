module poincare.tiling;

import std.stdio;
import std.math;
import std.conv;
import std.algorithm.comparison;

import raylib;

import poincare.euclidean;
import poincare.poincare;
import poincare.rendering;


double tilingDistance(int p, int q) {
    return sqrt((tan(raylib.PI / 2 - raylib.PI / q) - tan(raylib.PI / p)) / (tan(raylib.PI / 2 - raylib.PI / q) + tan(raylib.PI / p)));
}
