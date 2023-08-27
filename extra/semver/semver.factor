! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs.extras combinators
combinators.short-circuit combinators.smart io kernel math
math.order math.parser multiline peg.ebnf sequences
sequences.deep sequences.extras splitting strings ;

IN: semver

TUPLE: semver
    { major integer }
    { minor integer }
    { patch integer }
    prerelease
    build ;

ERROR: malformed-semver obj ;

GENERIC: >semver ( obj -- semver )
M: semver >semver ;
M: string >semver
    dup "+" split1 [ "-" split1 ] dip [
        "." split [ string>number ] map
        dup { [ length 3 = ] [ [ integer? ] all? ] } 1&&
        [ nip first3 ] [ drop malformed-semver ] if
    ] 2dip semver boa ;

: semver>string ( semver -- string )
    [
        {
            [ major>> number>string "." ]
            [ minor>> number>string "." ]
            [ patch>> number>string ]
            [ prerelease>> [ f f ] [ "-" swap ] if-empty ]
            [ build>> [ f f ] [ "+" swap ] if-empty ]
        } cleave
    ] "" append-outputs-as ;

: semver. ( semver -- )
    semver>string print ;

: bump-major ( semver -- semver )
    f >>build dup {
        [ prerelease>> empty? ]
        [ minor>> zero? not ]
        [ patch>> zero? not ]
    } 1|| [
        [ 1 + ] change-major
        0 >>minor
        0 >>patch
    ] when f >>prerelease ;

: bump-minor ( semver -- semver )
    f >>build dup {
        [ prerelease>> empty? ]
        [ patch>> zero? not ]
    } 1|| [
        [ 1 + ] change-minor
        0 >>patch
    ] when f >>prerelease ;

: bump-patch ( semver -- semver )
    f >>build dup prerelease>> empty? [
        [ 1 + ] change-patch
    ] when f >>prerelease ;

: bump-prerelease ( semver id -- semver )
    over prerelease>> [
        [ bump-patch ] dip [ "0" ] [ ".0" append ] if-empty
    ] [
        2dup swap head? [
            "." split
            dup [ string>number ] find-last [
                over [ string>number 1 + number>string ] change-nth
                "." join nip
            ] [
                2drop [ "0" ] [ ".0" append ] if-empty
            ] if
        ] [
            drop [ "0" ] [ ".0" append ] if-empty
        ] if
    ] if-empty >>prerelease f >>build ;

: bump-dev ( semver -- semver ) f bump-prerelease ;

: bump-alpha ( semver -- semver ) "alpha" bump-prerelease ;

: bump-beta ( semver -- semver ) "beta" bump-prerelease ;

: bump-rc ( semver -- semver ) "rc" bump-prerelease ;

: bump-premajor ( semver -- semver )
    [ 1 + ] change-major 0 >>minor 0 >>patch "0" >>prerelease f >>build ;

: bump-preminor ( semver -- semver )
    [ 1 + ] change-minor 0 >>patch "0" >>prerelease f >>build ;

: bump-prepatch ( semver -- semver )
    [ 1 + ] change-patch "0" >>prerelease f >>build ;

: lower-range ( semver -- str )
    semver>string ">=" prepend ;

: upper-range ( semver -- str )
    semver>string "<=" prepend ;

<PRIVATE

: major<=> ( semvar1 semvar2 -- <=> ) [ major>> ] compare ; inline

: minor<=> ( semvar1 semvar2 -- <=> ) [ minor>> ] compare ; inline

: patch<=> ( semvar1 semvar2 -- <=> ) [ patch>> ] compare ; inline

: prerelease<=> ( semver1 semver2 -- <=> )
    [ prerelease>> ] bi@ {
        { [ over empty? ] [ nip empty? +eq+ +gt+ ? ] }
        { [ dup empty? ] [ 2drop +lt+ ] }
        [
            [ "." split [ [ string>number ] keep or ] map ] bi@
            zip-longest [
                first2 {
                    { [ over not ] [ 2drop +lt+ ] }
                    { [ dup not ] [ 2drop +gt+ ] }
                    { [ 2dup [ integer? ] both? ] [ <=> ] }
                    { [ 2dup [ string? ] both? ] [ <=> ] }
                    { [ over integer? ] [ 2drop +lt+ ] }
                    { [ dup integer? ] [ 2drop +gt+ ] }
                    [ 2drop +eq+ ]
                } cond dup +eq+ eq? [ drop f ] when
            ] map-find drop +eq+ or
        ]
    } cond ; inline

PRIVATE>

M: semver <=>
    2dup major<=> dup +eq+ eq? [
        drop 2dup minor<=> dup +eq+ eq? [
            drop 2dup patch<=> dup +eq+ eq? [
                drop prerelease<=>
            ] [ 2nip ] if
        ] [ 2nip ] if
    ] [ 2nip ] if ;

: semver<=> ( obj1 obj2 -- <=> ) [ >semver ] compare ; inline

! caret - up to next major versions, aka only major version needs to match as long as minor/patch are >=
! tilde - last number can increment, e.g. ~1.2 is <2.0, ~1.2.3 is <1.3

SINGLETONS: major minor patch prerelease build prepatch preminor premajor ;

: first-semver-slot ( semver -- class )
    {
        { [ dup major>> 0 > ] [ drop major ] }
        { [ dup minor>> 0 > ] [ drop minor ] }
        { [ dup patch>> 0 > ] [ drop patch ] }
        { [ dup prerelease>> length 0 > ] [ drop prerelease ] }
        { [ dup build>> length 0 > ] [ drop build ] }
        [ drop major ]
    } cond ;

: last-semver-slot ( semver -- class )
    {
        { [ dup build>> length 0 > ] [ drop build ] }
        { [ dup prerelease>> length 0 > ] [ drop prerelease ] }
        { [ dup patch>> 0 > ] [ drop patch ] }
        { [ dup minor>> 0 > ] [ drop minor ] }
        { [ dup major>> 0 > ] [ drop major ] }
        [ drop major ]
    } cond ;

EBNF: parse-semver-range [=[
    logical-or = [\s\t]*~  '||'  [\s\t]*~
    range      = hyphen | simple ( [\s\t]*~ simple )*  => [[ first2 swap prefix ]]
    hyphen     = partial:p1 [\s\t]*~ '-':t  [\s\t]*~  partial:p2 => [[ p1 t  p2 3array ]]
    simple     = primitive | partial | tilde | caret
    primitive  = ( '~>' | '>=' | '<=' | '>' | '<' | '=' ) [\s\t]*~ partial
    partial    = xr ( '.' xr ( '.' xr qualifier? )? )? => [[ flatten concat ]]
    xr         = 'x' | 'X' | "*" | nr
    nr         = [0-9]+ => [[ string>number number>string ]]
    tilde      = '~'  [\s\t]*~  partial
    caret      = '^'  [\s\t]*~  partial
    qualifier  = ( '-' pre )? ( '+' build )?
    pre        = parts
    build      = parts
    parts      = part ( '.' part )*
    part       = nr | [-0-9A-Za-z]+ => [[ >string ]]
    range-set  = range? ( logical-or range? )* => [[ first2 swap prefix ]]
]=]
