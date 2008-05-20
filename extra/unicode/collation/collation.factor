USING: sequences io.files io.encodings.ascii kernel values
splitting accessors math.parser ascii io assocs strings math
namespaces sorting combinators math.order arrays
unicode.normalize ;
IN: unicode.collation

VALUE: ducet

TUPLE: weight primary secondary tertiary ignorable? ;

: remove-comments ( lines -- lines )
    [ "#" split1 drop "@" split1 drop ] map
    [ empty? not ] filter ;

: parse-weight ( string -- weight )
    "]" split but-last [
        weight new swap rest unclip CHAR: * = swapd >>ignorable?
        swap "." split first3 [ hex> ] tri@
        [ >>primary ] [ >>secondary ] [ >>tertiary ] tri*
    ] map ;

: parse-line ( line -- code-poing weight )
    ";" split1 [ [ blank? ] trim ] bi@
    [ " " split [ hex> ] "" map-as ] [ parse-weight ] bi* ;

: parse-ducet ( stream -- ducet )
    lines remove-comments
    [ parse-line ] H{ } map>assoc ;

"resource:extra/unicode/collation/allkeys.txt"
ascii <file-reader> parse-ducet \ ducet set-value

: derive-weight ( char -- weight )
    ! This should check Noncharacter_Code_Point
    ! If yes, then ignore the character
    ! otherwise, apply derivation formula
    drop { } ;

: string>weights ( string -- weights )
    ! This should actually look things up with
    ! multichar collation elements
    ! Also, do weight derivation for things not in DUCET
    [ dup 1string ducet at [ ] [ derive-weight ] ?if ]
    { } map-as concat ;

: append-weights ( weights quot -- )
    swap [ ignorable?>> not ] filter
    swap map [ zero? not ] filter % 0 , ;

: variable-weight ( weight -- )
    dup ignorable?>> [ primary>> ] [ drop HEX: FFFF ] if , ;

: weights>bytes ( weights -- byte-array )
    [
        {
            [ [ primary>> ] append-weights ]
            [ [ secondary>> ] append-weights ]
            [ [ tertiary>> ] append-weights ]
            [ [ variable-weight ] each ]
        } cleave
    ] { } make ;

: completely-ignorable? ( weight -- ? )
    [ primary>> ] [ secondary>> ] [ tertiary>> ] tri
    [ zero? ] tri@ and and ;

: filter-ignorable ( weights -- weights' )
    ! Filters primary-ignorables which follow variable weighteds
    ! and all completely-ignorables
    >r f r> [
        tuck primary>> zero? and
        [ swap ignorable?>> or ]
        [ swap completely-ignorable? or not ] 2bi
    ] filter nip ;

: collation-key ( string -- key )
    nfd string>weights filter-ignorable weights>bytes ;

: compare-collation ( {str1,key} {str2,key} -- <=> )
    2dup [ second ] bi@ <=> dup +eq+ =
    [ drop <=> ] [ 2nip ] if ;

: sort-strings ( strings -- sorted )
    [ dup collation-key ] { } map>assoc
    [ compare-collation ] sort
    keys ;

: string<=> ( str1 str2 -- <=> )
    [ dup collation-key 2array ] bi@ compare-collation ;
