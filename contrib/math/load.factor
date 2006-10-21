REQUIRES: contrib/sequences ;
PROVIDE: contrib/math
{ +files+ {
    "utils.factor"
    "combinatorics.factor"
    "analysis.factor"
    "polynomials.factor"
    "quaternions.factor"
    "matrices.factor"
    "statistics.factor"
    "numerical-integration.factor"
} }
{ +tests+ {
    "test.factor"
} } ;
