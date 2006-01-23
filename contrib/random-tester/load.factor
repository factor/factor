USING: kernel parser sequences words compiler ;
IN: scratchpad

"contrib/math/utils.factor" run-resource

{
    "utils"
    "random"
    "random-tester"
} [ "/contrib/random-tester/" swap ".factor" append3 run-resource ] each
