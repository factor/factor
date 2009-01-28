! Copyright (C) 2008 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: unicode.data kernel math sequences parser lexer
bit-arrays namespaces make sequences.private arrays quotations
assocs classes.predicate math.order strings.parser ;
IN: unicode.syntax

! Character classes (categories)

: category# ( char -- category )
    ! There are a few characters that should be Cn
    ! that this gives Cf or Mn
    ! Cf = 26; Mn = 5; Cn = 29
    ! Use a compressed array instead?
    dup category-map ?nth [ ] [
        dup HEX: E0001 HEX: E007F between?
        [ drop 26 ] [
            HEX: E0100 HEX: E01EF between?  5 29 ?
        ] if
    ] ?if ;

: category ( char -- category )
    category# categories nth ;

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

: CATEGORY:
    CREATE ";" parse-tokens define-category ; parsing

: seq-minus ( seq1 seq2 -- diff )
    [ member? not ] curry filter ;

: CATEGORY-NOT:
    CREATE ";" parse-tokens
    categories swap seq-minus define-category ; parsing
