USING: help.markup help.syntax ;
IN: boids.benchmark

HELP: boids-benchmark
{ $description "Prints median simulation step times in milliseconds for fixed, seeded flocks at several populations and window sizes. Each result is the median of five batches after three warmup steps. The timings include spatial indexing and steering calculations, and exclude drawing. A densely packed case measures the remaining worst case where most birds are neighbors." }
{ $notes "Run with " { $snippet "./factor -no-user-init -run=boids.benchmark" } "." } ;
