IN: dimensions
USING: parser sequences words compiler ;
[
    "contrib/math/utils.factor"
    "contrib/math/combinatorics.factor"
    "contrib/math/analysis.factor"
    "contrib/math/polynomials.factor"
    "contrib/math/quaternions.factor"
    "contrib/math/matrices.factor"
    "contrib/math/statistics.factor"
] [ run-file ] each

"math-contrib" words [ try-compile ] each

