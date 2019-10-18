REQUIRES: core/compiler/inference core/compiler/optimizer
core/compiler/generator core/compiler/alien ;

PROVIDE: core/compiler
{ +files+ {
    "compiler.factor"
    "compiler.facts"
} }
{ +tests+ {
    "test/templates-early.factor"
    "test/def-use.factor"
    "test/simple.factor"
    "test/templates.factor"
    "test/stack.factor"
    "test/ifte.factor"
    "test/generic.factor"
    "test/bail-out.factor"
    "test/intrinsics.factor"
    "test/float.factor"
    "test/class-infer.factor"
    "test/identities.factor"
    "test/optimizer.factor"
    "test/stack-trace.factor"
    "test/redefine.factor"
} } ;
