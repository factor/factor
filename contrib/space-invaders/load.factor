IN: scratchpad
USING: kernel parser compiler words sequences io ;

"/contrib/parser-combinators/load.factor" run-resource

{
    "cpu-8080"
    "space-invaders"
} [ "/contrib/space-invaders/" swap ".factor" append3 run-resource ] each
