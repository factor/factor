USING: kernel parser sequences words compiler ;
IN: scratchpad

{
    "utils"
    "random-tester"
} [ "/contrib/random-tester/" swap ".factor" append3 run-resource ] each
