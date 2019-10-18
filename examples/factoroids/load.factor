USING: kernel io parser sequences ;

{
    "utils"
    "models"
    "bodies"
    "actors"
    "projectiles"
    "ai"
    "input"
    "factoroids"
} [ "/examples/factoroids/" swap ".factor" append3 run-resource ] each

"To play Factoroids, enter the following in the listener:" print
terpri
"  USE: factoroids" print
"  factoroids" print
