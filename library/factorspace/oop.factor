! :sidekick.parser=none:
IN: oop

USE: combinators
USE: errors
USE: kernel
USE: lists
USE: namespaces
USE: parser
USE: stack
USE: strings
USE: words

SYMBOL: traits

: traits-map ( word -- hash )
    #! The method map word property maps selector words to
    #! definitions.
    "traits-map" word-property ;

: object-map ( obj -- hash )
    dup has-namespace? [ traits swap get* ] [ drop f ] ifte ;

: init-traits-map ( word -- )
    <namespace> "traits-map" set-word-property ;

: no-method
    "No applicable method." throw ;

: method ( traits selector -- quot )
    #! Execute the method with the traits object on the stack.
    over object-map get* [ [ no-method ] ] unless* ;

: constructor-word ( word -- word )
    word-name "<" swap ">" cat3 "in" get create ;

: define-constructor ( word -- )
    #! <foo> where foo is a traits type creates a new instance
    #! of foo.
    [ constructor-word [ <namespace> ] ] keep
    traits-map [ traits pick set* ] cons append
    define-compound ;

: predicate-word ( word -- word )
    word-name "?" cat2 "in" get create ;

: define-predicate ( word -- )
    #! foo? where foo is a traits type tests if the top of stack
    #! is of this type.
    dup predicate-word swap
    [ object-map ] swap traits-map [ eq? ] cons append
    define-compound ;

: TRAITS:
    #! TRAITS: foo creates a new traits type. Instances can be
    #! created with <foo>, and tested with foo?.
    CREATE
    dup define-symbol
    dup init-traits-map
    dup define-constructor
    define-predicate ; parsing

: GENERIC:
    #! GENERIC: bar creates a generic word bar that calls the
    #! bar method on the traits object, with the traits object
    #! on the namestack.
    CREATE
    dup unit [ car method bind ] cons
    define-compound ; parsing

: M:
    #! M: foo bar begins a definition of the bar generic word
    #! specialized to the foo type.
    scan-word scan-word f ; parsing

: ;M
    #! ;M ends a method definition.
    reverse transp traits-map set* ; parsing
