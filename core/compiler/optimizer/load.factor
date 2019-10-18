REQUIRES: core/compiler/inference ;

PROVIDE: core/compiler/optimizer
{ +files+ {
    "specializers.factor"
    "pattern-match.factor"
    "constraints.factor"
    "class-infer.factor"
    "def-use.factor"
    "optimizer.factor"
    "known-words.factor"
    "math.factor"
} } ;
