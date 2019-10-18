REQUIRES: libs/sequences ;
PROVIDE: libs/math
{ +files+ {
    "utils.factor"
    "combinatorics.factor"
    "analysis.factor"
    "polynomials.factor"
    "quaternions.factor"
    "statistics.factor"
    "numerical-integration.factor"
} }
{ +tests+ {
    "test.factor"
} } ;
