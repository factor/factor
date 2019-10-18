! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs calendar.english combinators
combinators.smart io.encodings.utf8 io.files kernel math.parser
memoize namespaces sequences splitting unicode ;
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
    "vocab:zoneinfo/solar87"
    "vocab:zoneinfo/solar88"
    "vocab:zoneinfo/solar89"
    "vocab:zoneinfo/southamerica"
    "vocab:zoneinfo/systemv"
    "vocab:zoneinfo/leapseconds"
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
        {
            [ drop ]
            [ ]
            [ ]
            [ ]
            [ ]
            [ ]
            [ ]
            [ ]
            [ ]
            [ ]
        } spread
    ] input<sequence raw-rule boa ;

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

: parse-link ( seq -- link )
    [
        {
            [ drop ]
            [ ]
            [ ]
        } spread
    ] input<sequence raw-link boa ;

: parse-leap ( seq -- link )
    [
        {
            [ drop ]
            [ ]
            [ ]
            [ ]
            [ ]
            [ ]
            [ ]
        } spread
    ] input<sequence raw-leap boa ;

: parse-line ( seq -- tuple )
    dup first >lower
    {
        { "zone" [ parse-zone dup last-zone set ] }
        { "rule" [ parse-rule ] }
        { "link" [ parse-link ] }
        { "leap" [ parse-leap ] }
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

GENERIC: zone-matches? ( string rule -- ? )

M: raw-rule zone-matches? name>> = ;
M: raw-zone zone-matches? name>> = ;
M: raw-link zone-matches? from>> = ;
M: raw-leap zone-matches? 2drop f ;

: find-rules ( string -- rules )
    raw-rule-map
    [ [ to>> "max" = ] filter ] assoc-map at ;

ERROR: zone-not-found name ;

: find-zone ( string -- rules )
    raw-zone-map
    [ last ] assoc-map ?at [ zone-not-found ] unless ;

: find-zone-rules ( string -- zone rules )
    find-zone dup rules/save>> find-rules ;

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

! "Europe/Helsinki" find-zone-rules

! Rule
! name - string
! from - year or "min"
! name    "France"
! from    "1938"  or "min"
! to      "1945" or "max" or "only"
! type    "-"  always "-"
! in      "Mar"  -- 3-letter month name
! on      "26"  or "Mon>=15"  or lastSun lastFri
! at      "23:00s"  "12:13:00s" "1:00s" "1:00u"
! save    "-0:00:05" "1:00" "0:14:15"
! letters "S" or "-" or "AMT" "BDST"

! Zone
! name       "Indian/Maldives"
! gmt-offset "4:54:00" "9:55:56" "-9:55:56"
! rules/save "-" "0:20" "0:30" "1:00" "AN" "W-Eur" "Winn" "Zion" "sol87" "sol88"
! format     "LMT" "%s" "%sT" "A%sT" "AC%sT" "ACT"
! until      { "1880" }
    ! { "1847" "Dec" "1" "0:00s" }
    ! { "1883" "Nov" "18" "12:12:57" }
    ! { "1989" "Sep" "lastSun" "2:00s" }

! Link
! T{ link { from "Asia/Riyadh88" } { to "Mideast/Riyadh88" } }
