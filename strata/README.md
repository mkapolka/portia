# STRATA Test
Idea here is that we'll have a strict distinction between state data & behavior
All the game's state data will live in a big global data structure, inspired by
a global heap but with a tree structure. Components will live in static space and will base
their behavior on this stuff.
