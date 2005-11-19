USING: io parser ;

"examples/factoroids/utils.factor" run-file
"examples/factoroids/models.factor" run-file
"examples/factoroids/bodies.factor" run-file
"examples/factoroids/actors.factor" run-file
"examples/factoroids/projectiles.factor" run-file
"examples/factoroids/ai.factor" run-file
"examples/factoroids/input.factor" run-file
"examples/factoroids/factoroids.factor" run-file

"To play Factoroids, enter the following in the listener:" print
terpri
"  USE: factoroids" print
"  factoroids" print
