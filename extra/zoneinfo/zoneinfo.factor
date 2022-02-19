! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays ascii assocs assocs.extras calendar
calendar.english combinators combinators.short-circuit
combinators.smart csv grouping interval-maps io.encodings.utf8
io.files kernel math math.parser memoize namespaces sequences
sequences.extras sorting splitting splitting.extras ;
QUALIFIED: sets
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
    "vocab:zoneinfo/backzone"
}

CONSTANT: zoneinfo-extra-paths
{
    "vocab:zoneinfo/backward"
    "vocab:zoneinfo/etcetera"
    "vocab:zoneinfo/factory"
    "vocab:zoneinfo/leapseconds"
    "vocab:zoneinfo/systemv"
}

: zoneinfo-lines ( path -- seq )
    utf8 file-lines
    [
        { [ length 0 = ] [ "#" head? ] } 1||
    ] reject
    [ "\t " split ] map ;

MEMO: zoneinfo-country-zones ( -- seq )
    "vocab:zoneinfo/zone1970.tab" zoneinfo-lines ;

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

: parse-zoneinfo-line ( seq -- tuple )
    dup first >lower
    {
        { "rule" [ parse-rule ] }
        { "link" [ parse-link ] }
        { "leap" [ parse-leap ] }
        { "zone" [ parse-zone dup last-zone set ] }
        [ drop harvest parse-partial-zone ]
    } case ;

: parse-zoneinfo-file ( path -- seq )
    zoneinfo-lines [ parse-zoneinfo-line ] map ;

MEMO: zoneinfo-files ( -- seq )
    zoneinfo-paths [ parse-zoneinfo-file ] map ;

MEMO: zoneinfo-array ( -- seq )
    zoneinfo-files concat ;

MEMO: zoneinfo-assoc ( -- assoc )
    zoneinfo-paths [ dup parse-zoneinfo-file ] { } map>assoc ;

: raw-rule-map ( -- assoc )
    zoneinfo-array [ raw-rule? ] filter [ name>> ] collect-by ;

: current-rule-map ( -- assoc )
    raw-rule-map
    [ [ to>> "max" = ] filter ] assoc-map
    harvest-values ;

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
        find-zone-rules
        [ format>> ] dip
        [
            letters>> dup { "D" "S" } member? [ drop "" ] unless
            swap "%" split1
            [ 1 tail surround ] [ nip ] if*
        ] with V{ } map-as sets:members
    ] zip-with ;

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

: zone-month ( timestamp month -- timestamp' )
    month-abbreviation-index >>month ;

ERROR: unknown-day-abbrev day ;
: day-abbrev>= ( timestamp day -- timestamp' )
    {
        { "Sun" [ sunday>= ] }
        { "Mon" [ monday>= ] }
        { "Tue" [ tuesday>= ] }
        { "Wed" [ wednesday>= ] }
        { "Thu" [ thursday>= ] }
        { "Fri" [ friday>= ] }
        { "Sat" [ saturday>= ] }
        [ unknown-day-abbrev ]
    } case ;

: day-abbrev<= ( timestamp day -- timestamp' )
    {
        { "Sun" [ sunday<= ] }
        { "Mon" [ monday<= ] }
        { "Tue" [ tuesday<= ] }
        { "Wed" [ wednesday<= ] }
        { "Thu" [ thursday<= ] }
        { "Fri" [ friday<= ] }
        { "Sat" [ saturday<= ] }
        [ unknown-day-abbrev ]
    } case ;

: comparison-day-string ( timestamp string -- timestamp )
    {
        { [ ">=" over subseq? ] [ ">=" split1 swap [ string>number >>day ] dip day-abbrev>= ] }
        { [ "<=" over subseq? ] [ "<=" split1 swap [ string>number >>day ] dip day-abbrev<= ] }
        [ string>number >>day ]
    } cond ;
        
ERROR: unknown-last-day string ;

: last-day-string ( timestamp string -- timestamp )
    {
        { "lastSun" [ last-sunday-of-month ] }
        { "lastMon" [ last-monday-of-month ] }
        { "lastTue" [ last-tuesday-of-month ] }
        { "lastWed" [ last-wednesday-of-month ] }
        { "lastThu" [ last-thursday-of-month ] }
        { "lastFri" [ last-friday-of-month ] }
        { "lastSat" [ last-saturday-of-month ] }
        [ unknown-last-day ]
    } case ;

!  "lastFri" | "Fri<=1" | "Sat>=2" | "15"
: zone-day ( timestamp text -- timestamp' )
    dup "last" head? [
        last-day-string
    ] [
        comparison-day-string
    ] if ;

: string>year ( str -- year )
    string>number <year-gmt> ;

: rule-year>years ( rule -- from to )
    [ from>> ] [ to>> ] bi
    {
        { [ over "min" = ] [ [ drop -1/0. ] [ string>year ] bi* ] }
        { [ dup "max" = ] [ [ string>year ] [ drop 1/0. ] bi* ] }
        { [ dup "only" = ] [ drop dup [ string>year ] bi@ ] }
        [ [ string>year ] bi@ ]
    } cond ;

: parse-hms ( str -- hms-seq )
    ":" split [ string>number ] map 3 0 pad-tail ;

: parse-offset ( str -- hms-seq )
    "-" ?head [ parse-hms ] dip [ [ neg ] map ] when ;

! XXX: Don't just drop the s/u, e.g. 2:00:00s
: zone-time ( timestamp time -- timestamp' )
    [ Letter? ] split-tail drop
    parse-offset first3 set-time ;

: hm>duration ( str -- duration )
    ":" split1 "0" or [ string>number ] bi@
    [ instant ] 2dip 0 set-time ;

: rule>timestamp-rest ( timestamp zone -- from )
    {
        [ over fp-infinity? [ drop ] [ in>> month-abbreviation-index >>month ] if ]
        [ over fp-infinity? [ drop ] [ on>> zone-day ] if ]
        [ over fp-infinity? [ drop ] [ at-time>> zone-time ] if ]
    } cleave ;

: rule>timestamps ( zone -- from to )
    [ rule-year>years ] keep
    [ nip rule>timestamp-rest ]
    [ nipd rule>timestamp-rest ] 3bi ;

: until>timestamp ( seq -- unix-time )
    [ 1/0. ] [
        4 f pad-tail first4 {
            [ string>number <year-gmt> ]
            [ [ zone-month ] when* ]
            [ [ zone-day ] when* ]
            [ [ zone-time ] when* ]
        } spread timestamp>unix-time
    ] if-empty ;

: zones>interval-map ( zones -- interval-map )
    [
        [ until>> until>timestamp ] map
        -1/0. prefix 2 <clumps> [ >array ] map
    ] keep zip
    [ first2 1 - 2array ] map-keys <interval-map> ;

: name>zones ( name -- interval-map )
    raw-zone-map at zones>interval-map ;

: gmt-offset ( timestamp name -- gmt-offset )
    [ timestamp>unix-time ]
    [ zones>interval-map ] bi* interval-at ;

: name>rules ( name -- rules )
    raw-rule-map at [
        [
            [ rule>timestamps [ dup fp-infinity? [ timestamp>unix-time ] unless ] bi@ 2array ]
            [ [ save>> hm>duration ] [ letters>> ] bi 2array ] bi 2array
        ] map
    ] keep zip ;

: chicago-zones ( -- interval-map ) "America/Chicago" name>zones ;
: us-rules ( -- rules ) "US" name>rules ;
