REQUIRES: core/compiler/generator ;

PROVIDE: core/compiler/alien
{ +files+ {
    "aliens.factor"
    "c-types.factor"
    "primitive-types.factor"
    "structs.factor"
    "compiler.factor"
    "alien-invoke.factor"
    "alien-callback.factor"
    "alien-indirect.factor"
    "prettyprint.factor"
    "syntax.factor"
    "remote-control.factor"

    "alien-callback.facts"
    "alien-indirect.facts"
    "alien-invoke.facts"
    "aliens.facts"
    "c-types.facts"
    "structs.facts"
    "syntax.facts"
} }
{ +tests+ {
    "test/alien-objects.factor"
    "test/c-types.factor"
    "test/alien.factor"
    "test/callbacks.factor"
} } ;
