IN: components
USING: help inspector kernel namespaces sequences words ;

! Component document framework, like OpenDoc.

TUPLE: component name predicate builder ;

SYMBOL: components

V{ } clone components set-global

: get-components ( obj -- seq )
    components get-global
    [ component-predicate call ] subset-with ;

: define-component ( name predicate builder -- )
    <component> components get-global push ;

"Slots" [ drop t ] [ describe ] define-component
"Documentation" [ word? ] [ help ] define-component
"Calls in" [ word? ] [ usage. ] define-component
"Calls out" [ word? ] [ uses. ] define-component
"Definition" [ term? ] [ help ] define-component
"Documentation" [ link? ] [ help ] define-component
