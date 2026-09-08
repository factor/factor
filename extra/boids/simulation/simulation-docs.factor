USING: help.markup help.syntax math sequences ;
IN: boids.simulation

HELP: wrap-pos-in
{ $values { "pos" sequence } { "dim" sequence } }
{ $description "Wraps a position into the given dimensions. Each extent is clamped to at least one so temporarily empty layouts remain usable." } ;

HELP: simulate-in
{ $values { "boids" sequence } { "behaviors" sequence } { "dt" number }
    { "dim" sequence } }
{ $description "Advances the flock by one step and wraps positions within the given dimensions. The boids gadget supplies its current allocated size." } ;

HELP: random-boids-in
{ $values { "count" integer } { "dim" sequence } { "boids" sequence } }
{ $description "Creates a flock with positions inside the given dimensions and random velocities. Integer extents are clamped to at least one." } ;

HELP: simulate
{ $values { "boids" sequence } { "behaviors" sequence } { "dt" number } }
{ $description "Advances a flock within the default 512 by 512 area. Use " { $link simulate-in } " for another size." } ;
