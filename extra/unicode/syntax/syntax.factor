USING: unicode.data kernel math sequences parser bit-arrays namespaces 
sequences.private arrays quotations classes.predicate ;
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
    categories [ swap member? ] curry* map >bit-array ;

: as-string ( strings -- bit-array )
    concat "\"" tuck 3append parse first ;

: [category] ( categories -- quot )
    [
        [ [ categories member? not ] subset as-string ] keep 
        [ categories member? ] subset >category-array
        [ dup category# ] % , [ nth-unsafe [ drop t ] ] %
        \ member? 2array >quotation ,
        \ if ,
    ] [ ] make ;

: define-category ( word categories -- )
    [category] fixnum -rot define-predicate-class ;

: CATEGORY:
    CREATE ";" parse-tokens define-category ; parsing

: seq-minus ( seq1 seq2 -- diff )
    [ member? not ] curry subset ;

: CATEGORY-NOT:
    CREATE ";" parse-tokens
    categories swap seq-minus define-category ; parsing

TUPLE: code-point lower title upper ;

C: <code-point> code-point

: set-code-point ( seq -- )
    4 head [ multihex ] map first4
    <code-point> swap first set ;

: UNICHAR:
    ! This should be part of CHAR:
    scan name>char [ parsed ] [ "Invalid character" throw ] if* ; parsing
