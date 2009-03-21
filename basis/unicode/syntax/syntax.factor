! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: unicode.data kernel math sequences parser lexer
bit-arrays namespaces make sequences.private arrays quotations
assocs classes.predicate math.order strings.parser ;
IN: unicode.syntax

<PRIVATE

: >category-array ( categories -- bitarray )
    categories [ swap member? ] with map >bit-array ;

: as-string ( strings -- bit-array )
    concat unescape-string ;

: [category] ( categories -- quot )
    [
        [ [ categories member? not ] filter as-string ] keep 
        [ categories member? ] filter >category-array
        [ dup category# ] % , [ nth-unsafe [ drop t ] ] %
        \ member? 2array >quotation ,
        \ if ,
    ] [ ] make ;

: define-category ( word categories -- )
    [category] integer swap define-predicate-class ;

PRIVATE>

SYNTAX: CATEGORY:
    CREATE ";" parse-tokens define-category ;

: seq-minus ( seq1 seq2 -- diff )
    [ member? not ] curry filter ;

SYNTAX: CATEGORY-NOT:
    CREATE ";" parse-tokens
    categories swap seq-minus define-category ;
