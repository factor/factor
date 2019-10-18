PROVIDE: core/compiler/inference
{ +files+ {
    "shuffle.factor"
    "dataflow.factor"
    "variables.factor"
    "inference.factor"
    "branches.factor"
    "words.factor"
    "stack.factor"
    "known-words.factor"
    "transforms.factor"
    "errors.factor"

    "branches.facts"
    "dataflow.facts"
    "inference.facts"
    "shuffle.facts"
    "stack.facts"
    "words.facts"
} }
{ +tests+ {
    "test/inference.factor"
    "test/transforms.factor"
} } ;
