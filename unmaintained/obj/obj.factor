
USING: kernel words namespaces arrays vectors hashtables
       sequences assocs sets grouping
       combinators.conditional
       combinators.short-circuit
       obj.util obj.alist ;

IN: obj

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: properties ( -- properties ) V{ } ;

SYM: self  properties adjoin
SYM: type  properties adjoin
SYM: title properties adjoin

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: types ( -- types ) V{ } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: >obj ( val -- obj ) [ symbol? ] [ get ] [ ] 1if ;

: -> ( obj pro -- val ) swap >obj at ;

PREDICATE: obj < alist { [ self -> ] [ type -> ] } 1&& ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: objects ( -- objects ) V{ } ;

: define-object ( symbol table -- )
  2 group >vector
  self rot 2array prefix
  dup dup self -> set-global
  self -> objects adjoin ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

PREDICATE: ptr < symbol get obj? ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

