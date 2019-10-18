IN: scratchpad
USING: kernel parser sequences words compiler ;

{ 
    "utils"
    "combinatorics"
    "analysis"
    "polynomials"
    "quaternions"
    "matrices"
    "statistics"
    "numerical-integration"
} [ "/contrib/math/" swap ".factor" append3 run-resource ] each
