! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar.english combinators
combinators.smart io.encodings.utf8 io.files kernel math.parser
memoize namespaces sequences sequences.extras sorting splitting
unicode ;
IN: zoneinfo

CONSTANT: zoneinfo-paths
{
    "vocab:zoneinfo/africa"
    "vocab:zoneinfo/antarctica"
    "vocab:zoneinfo/asia"
    "vocab:zoneinfo/australasia"
    "vocab:zoneinfo/europe"
    "vocab:zoneinfo/northamerica"
    "vocab:zoneinfo/pacificnew"
    "vocab:zoneinfo/southamerica"
    "vocab:zoneinfo/etcetera"
    "vocab:zoneinfo/factory"
    "vocab:zoneinfo/leapseconds"
    "vocab:zoneinfo/systemv"
}

SYMBOL: last-zone

TUPLE: raw-zone name gmt-offset rules/save format until ;
TUPLE: raw-rule name from to type in on at-time save letters ;
TUPLE: raw-link from to ;
TUPLE: raw-leap year month day hms corr r/s ;

TUPLE: zone name ;
TUPLE: rule name from to at-time ;

: rule-to ( m string -- m n )
    {
        { "only" [ dup ] }
        { "max" [ 1/0. ] }
        [ string>number ]
    } case ;

: parse-rule ( seq -- rule )
    [
        { [ drop ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] [ ] } spread
    ] input<sequence raw-rule boa ;

: parse-link ( seq -- link )
    [
        { [ drop ] [ ] [ ] } spread
    ] input<sequence raw-link boa ;

: parse-leap ( seq -- link )
    [
        { [ drop ] [ ] [ ] [ ] [ ] [ ] [ ] } spread
    ] input<sequence raw-leap boa ;

: parse-zone ( seq -- zone )
    {
        [ second ]
        [ third ]
        [ fourth ]
        [ 4 swap nth ]
        [ 5 tail harvest ]
    } cleave raw-zone boa ;

: parse-partial-zone ( seq -- zone )
    [ last-zone get name>> ] dip
    {
        [ first ]
        [ second ]
        [ 2 swap nth ]
        [ 3 tail harvest ]
    } cleave raw-zone boa ;

: parse-line ( seq -- tuple )
    dup first >lower
    {
        { "rule" [ parse-rule ] }
        { "link" [ parse-link ] }
        { "leap" [ parse-leap ] }
        { "zone" [ parse-zone dup last-zone set ] }
        [ drop harvest parse-partial-zone ]
    } case ;

: parse-zoneinfo-file ( path -- seq )
    utf8 file-lines
    [ "#" split1 drop ] map harvest
    [ "\t " split harvest ] map harvest
    [ [ parse-line ] map ] with-scope ;

MEMO: zoneinfo-files ( -- seq )
    zoneinfo-paths [ parse-zoneinfo-file ] map ;

MEMO: zoneinfo-array ( -- seq )
    zoneinfo-files concat ;

: raw-rule-map ( -- assoc )
    zoneinfo-array [ raw-rule? ] filter [ name>> ] collect-by ;

: raw-zone-map ( -- assoc )
    zoneinfo-array [ raw-zone? ] filter [ name>> ] collect-by ;

: zoneinfo-zones ( -- seq )
    raw-zone-map keys
    [ "/" swap subseq? ] partition
    [ natural-sort ] bi@ append ;

GENERIC: zone-matches? ( string rule -- ? )

M: raw-rule zone-matches? name>> = ;
M: raw-link zone-matches? from>> = ;
M: raw-leap zone-matches? 2drop f ;
M: raw-zone zone-matches? name>> = ;

: find-rules ( string -- rules )
    raw-rule-map
    [ [ to>> "max" = ] filter ] assoc-map at ;

ERROR: zone-not-found name ;

: find-zone ( string -- zone )
    raw-zone-map
    [ last ] assoc-map ?at [ zone-not-found ] unless ;

: find-zone-rules ( string -- zone rules )
    find-zone dup rules/save>> find-rules ;

: zone-abbrevs ( -- assoc )
    zoneinfo-zones [
        find-zone-rules [ format>> ] dip
        [
            letters>> swap "%" split1 dup [ 1 tail ] when surround
        ] with V{ } map-as
    ] map-zip ;

: number>value ( n -- n' )
    {
        { "only" [ f ] }
        { "min" [ f ] }
        { "max" [ t ] }
        [ string>number ]
    } case ;

: on>value ( n -- n' )
    ! "3", "Thu>=8" always >=, "lastFri"
    {
        { [ dup 3 swap ?nth CHAR: > = ] [
            3 cut 2 tail [ day-abbreviation3-predicate ] [ string>number ] bi* 2array
        ] }
        { [ dup "last" head? ] [ 4 tail day-abbreviation3-index ] }
        [ string>number ]
    } cond ;

: raw-rule>triple ( raw-rule -- quot )
    {
        [ from>> string>number ]
        [ in>> month-abbreviation-index ]
        [ on>> on>value ]
    } cleave>array ;
