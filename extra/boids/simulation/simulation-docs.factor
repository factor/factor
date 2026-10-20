USING: help.markup help.syntax math sequences ;
IN: boids.simulation

HELP: wrap-pos-in
{ $values { "pos" sequence } { "dim" sequence } }
{ $description "Wraps a position into the given dimensions. Each extent is clamped to at least one so temporarily empty layouts remain usable." } ;

HELP: simulate-in
{ $values { "boids" sequence } { "behaviors" sequence } { "dt" number }
    { "dim" sequence } }
{ $description "Advances the two-dimensional flock by one step and wraps positions within the given dimensions. The boids gadget supplies its current allocated size. A spatial grid limits neighbor searches to nearby cells, using the largest behavior radius as the cell size. Distances and viewing angles use the original positions; opposite edges are not adjacent for neighbor searches. Grid traversal can change floating-point summation order." } ;

HELP: random-boids-in
{ $values { "count" integer } { "dim" sequence } { "boids" sequence } }
{ $description "Creates a flock with positions inside the given dimensions and random velocities. Integer extents are clamped to at least one." } ;

HELP: simulate
{ $values { "boids" sequence } { "behaviors" sequence } { "dt" number } }
{ $description "Advances a flock within the default 512 by 512 area. Use " { $link simulate-in } " for another size." } ;
