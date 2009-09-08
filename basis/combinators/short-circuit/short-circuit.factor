USING: kernel combinators quotations arrays sequences assocs
generalizations macros fry ;
IN: combinators.short-circuit

MACRO: n&& ( quots n -- quot )
    [
        [ [ f ] ] 2dip swap [
            [ '[ drop _ ndup @ dup not ] ]
            [ drop '[ drop _ ndrop f ] ]
            2bi 2array
        ] with map
    ] [ '[ _ nnip ] suffix 1array ] bi
    [ cond ] 3append ;

<PRIVATE

: unoptimized-&& ( quots quot -- ? )
    [ [ call dup ] ] dip call [ nip ] prepose [ f ] 2dip all? swap and ; inline

PRIVATE>

: 0&& ( quots -- ? ) [ ] unoptimized-&& ;
: 1&& ( obj quots -- ? ) [ with ] unoptimized-&& ;
: 2&& ( obj1 obj2 quots -- ? ) [ with with ] unoptimized-&& ;
: 3&& ( obj1 obj2 obj3 quots -- ? ) [ with with with ] unoptimized-&& ;

MACRO: n|| ( quots n -- quot )
    [
        [ [ f ] ] 2dip swap [
            [ '[ drop _ ndup @ dup ] ]
            [ drop '[ _ nnip ] ]
            2bi 2array
        ] with map
    ] [ '[ drop _ ndrop t ] [ f ] 2array suffix 1array ] bi
    [ cond ] 3append ;

<PRIVATE

: unoptimized-|| ( quots quot -- ? )
    [ [ call ] ] dip call map-find drop ; inline

PRIVATE>

: 0|| ( quots -- ? ) [ ] unoptimized-|| ;
: 1|| ( obj quots -- ? ) [ with ] unoptimized-|| ;
: 2|| ( obj1 obj2 quots -- ? ) [ with with ] unoptimized-|| ;
: 3|| ( obj1 obj2 obj3 quots -- ? ) [ with with with ] unoptimized-|| ;
