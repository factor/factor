! Copyright (C) 2007 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.tuple combinators
combinators.short-circuit kernel literals math math.constants
math.functions math.intervals math.order math.statistics
sequences system vocabs vocabs.loader ;
FROM: ranges => [a..b) ;
IN: calendar

ERROR: not-in-interval value interval ;

: check-interval ( value interval -- value )
    2dup interval-contains? [ drop ] [ not-in-interval ] if ;

HOOK: gmt-offset os ( -- hours minutes seconds )

ALIAS: utc-offset gmt-offset

HOOK: now-gmt os ( -- timestamp )

ALIAS: now-utc now-gmt

TUPLE: duration
    { year real }
    { month real }
    { day real }
    { hour real }
    { minute real }
    { second real } ;

C: <duration> duration

: instant ( -- duration ) 0 0 0 0 0 0 <duration> ;

TUPLE: timestamp
    { year integer }
    { month integer }
    { day integer }
    { hour integer }
    { minute integer }
    { second real }
    { gmt-offset duration } ;

<PRIVATE

<<
CONSTANT: day-counts { 0 31 28 31 30 31 30 31 31 30 31 30 31 }
>>
CONSTANT: cumulative-day-counts $[ day-counts cum-sum0 ]

PRIVATE>

GENERIC: leap-year? ( obj -- ? )

M: integer leap-year?
    dup 100 divisor? 400 4 ? divisor? ;

M: timestamp leap-year?
    year>> leap-year? ;

: (days-in-month) ( year month -- n )
    dup 2 = [ drop leap-year? 29 28 ? ] [ nip day-counts nth ] if ;

:: <timestamp> ( $year $month $day $hour $minute $second $gmt-offset -- timestamp )
    $year
    $month 1 12 [a,b] check-interval
    $day 1 $year $month (days-in-month) [a,b] check-interval
    $hour 0 23 [a,b] check-interval
    $minute 0 59 [a,b] check-interval
    $second 0 60 [a,b) check-interval
    $gmt-offset timestamp boa ;

M: timestamp clone (clone) [ clone ] change-gmt-offset ;

: gmt-offset-duration ( -- duration )
    0 0 0 gmt-offset <duration> ; inline

: <date> ( year month day -- timestamp )
    0 0 0 gmt-offset-duration <timestamp> ; inline

: <date-gmt> ( year month day -- timestamp )
    0 0 0 instant <timestamp> ; inline

ALIAS: <date-utc> <date-gmt>

: <year> ( year -- timestamp )
    1 1 <date> ; inline

: <year-gmt> ( year -- timestamp )
    1 1 <date-gmt> ; inline

ALIAS: <year-utc> <year-gmt>

CONSTANT: average-month 30+5/12
CONSTANT: months-per-year 12
CONSTANT: days-per-year 3652425/10000
CONSTANT: hours-per-year 876582/100
CONSTANT: minutes-per-year 5259492/10
CONSTANT: seconds-per-year 31556952

:: julian-day-number ( $year $month $day -- n )
    ! Returns a composite date number
    ! Not valid before year -4800
    14 $month - 12 /i :> $a
    $year 4800 + $a - :> $y
    $month 12 $a * + 3 - :> $m

    $day 153 $m * 2 + 5 /i + 365 $y * +
    $y 4 /i + $y 100 /i - $y 400 /i + 32045 - ;

:: julian-day-number>date ( $n -- year month day )
    ! Inverse of julian-day-number
    $n 32044 + :> $a
    4 $a * 3 + 146097 /i :> $b
    $a 146097 $b * 4 /i - :> $c
    4 $c * 3 + 1461 /i :> $d
    $c 1461 $d * 4 /i - :> $e
    5 $e * 2 + 153 /i :> $m

    100 $b * $d + 4800 -
    $m 10 /i + $m 3 +
    12 $m 10 /i * -
    $e 153 $m * 2 + 5 /i - 1 + ;

GENERIC: easter ( obj -- obj' )

:: easter-month-day ( $year -- month day )
    $year 19 mod :> $a
    $year 100 /mod :> ( $b $c )
    $b 4 /mod :> ( $d $e )
    $b 8 + 25 /i :> $f
    $b $f - 1 + 3 /i :> $g
    19 $a * $b + $d - $g - 15 + 30 mod :> $h
    $c 4 /mod :> ( $i $k )
    32 2 $e * + 2 $i * + $h - $k - 7 mod :> $l
    $a 11 $h * + 22 $l * + 451 /i :> $m

    $h $l + 7 $m * - 114 + 31 /mod 1 + ;

M: integer easter
    dup easter-month-day <date> ;

M: timestamp easter
    clone dup year>> easter-month-day
    swapd >>day swap >>month ;

: >date< ( timestamp -- year month day )
    [ year>> ] [ month>> ] [ day>> ] tri ;

: set-date ( timestamp year month day -- timestamp )
    [ >>year ] [ >>month ] [ >>day ] tri* ;

: >time< ( timestamp -- hour minute second )
    [ hour>> ] [ minute>> ] [ second>> ] tri ;

: set-time ( timestamp hour minute second -- timestamp )
    [ >>hour ] [ >>minute ] [ >>second ] tri* ;

: years ( x -- duration ) instant swap >>year ;
: bienniums ( x -- duration ) instant swap 2 * >>year ;
: trienniums ( x -- duration ) instant swap 3 * >>year ;
: quadrenniums ( x -- duration ) instant swap 4 * >>year ;
: quinquenniums ( x -- duration ) instant swap 5 * >>year ;
: sexenniums ( x -- duration ) instant swap 6 * >>year ;
: septenniums ( x -- duration ) instant swap 7 * >>year ;
: octenniums ( x -- duration ) instant swap 8 * >>year ;
: novenniums ( x -- duration ) instant swap 9 * >>year ;
: lustrums ( x -- duration ) instant swap 5 * >>year ;
: decades ( x -- duration ) instant swap 10 * >>year ;
: indictions ( x -- duration ) instant swap 15 * >>year ;
: score ( x -- duration ) instant swap 20 * >>year ;
: jubilees ( x -- duration ) instant swap 50 * >>year ;
: centuries ( x -- duration ) instant swap 100 * >>year ;
: millennia ( x -- duration ) instant swap 1000 * >>year ;
: millenniums ( x -- duration ) instant swap 1000 * >>year ;
: kila-annum ( x -- duration ) instant swap 1000 * >>year ;
: mega-annum ( x -- duration ) instant swap 1,000,000 * >>year ;
: giga-annum ( x -- duration ) instant swap 1,000,000,000 * >>year ;
: ages ( x -- duration ) instant swap 1,000,000 * >>year ;
: epochs ( x -- duration ) instant swap 10,000,000 * >>year ;
: eras ( x -- duration ) instant swap 100,000,000 * >>year ;
: eons ( x -- duration ) instant swap 500,000,000 * >>year ;
: months ( x -- duration ) instant swap >>month ;
: days ( x -- duration ) instant swap >>day ;
: weeks ( x -- duration ) 7 * days ;
: fortnight ( x -- duration ) 14 * days ;
: hours ( x -- duration ) instant swap >>hour ;
: minutes ( x -- duration ) instant swap >>minute ;
: seconds ( x -- duration ) instant swap >>second ;
: milliseconds ( x -- duration ) 1000 / seconds ;
: microseconds ( x -- duration ) 1000000 / seconds ;
: nanoseconds ( x -- duration ) 1000000000 / seconds ;

DEFER: days-in-month

<PRIVATE

GENERIC: +year ( timestamp x -- timestamp )
GENERIC: +month ( timestamp x -- timestamp )
GENERIC: +day ( timestamp x -- timestamp )
GENERIC: +hour ( timestamp x -- timestamp )
GENERIC: +minute ( timestamp x -- timestamp )
GENERIC: +second ( timestamp x -- timestamp )

: /rem ( f n -- q r )
    ! q is positive or negative, r is positive from 0 <= r < n
    [ /mod ] keep over 0 < [ + [ -1 + ] dip ] [ drop ] if ; inline

: float>whole-part ( float -- int float )
    [ floor >integer ] keep over - ; inline

: adjust-leap-year ( timestamp -- timestamp )
    dup
    { [ day>> 29 = ] [ month>> 2 = ] [ leap-year? not ] } 1&&
    [ 3 >>month 1 >>day ] when ;

M: integer +year
    [ + ] curry change-year adjust-leap-year ;

M: real +year
    float>whole-part swapd days-per-year * +day swap +year ;

: months/years ( n -- months years )
    12 /rem [ 1 - 12 ] when-zero swap ; inline

M: integer +month
    [
        over month>> + months/years
        [ >>month dup days-in-month '[ _ min ] change-day ] dip +year
    ] unless-zero ;

M: real +month
    float>whole-part swapd average-month * +day swap +month ;

M: integer +day
    [ over >date< julian-day-number + julian-day-number>date set-date ] unless-zero ;

M: real +day
    float>whole-part swapd 24 * +hour swap +day ;

: hours/days ( n -- hours days )
    24 /rem swap ; inline

M: integer +hour
    [ over hour>> + hours/days [ >>hour ] dip +day ] unless-zero ;

M: real +hour
    float>whole-part swapd 60 * +minute swap +hour ;

: minutes/hours ( n -- minutes hours )
    60 /rem swap ; inline

M: integer +minute
    [ over minute>> + minutes/hours [ >>minute ] dip +hour ] unless-zero ;

M: real +minute
    float>whole-part swapd 60 * +second swap +minute ;

: seconds/minutes ( n -- seconds minutes )
    60 /rem swap ; inline

M: number +second
    [ over second>> + seconds/minutes [ >>second ] dip +minute ] unless-zero ;

: (time+) ( timestamp duration -- timestamp )
    {
        [ second>> +second ]
        [ minute>> +minute ]
        [ hour>>   +hour   ]
        [ day>>    +day    ]
        [ month>>  +month  ]
        [ year>>   +year   ]
    } cleave ; inline

PRIVATE>

GENERIC#: time+ 1 ( time1 time2 -- time3 )

M: timestamp time+ [ clone ] dip (time+) ;

: duration+ ( duration1 duration2 -- duration3 )
    {
        [ [ year>> ] bi@ + ]
        [ [ month>> ] bi@ + ]
        [ [ day>> ] bi@ + ]
        [ [ hour>> ] bi@ + ]
        [ [ minute>> ] bi@ + ]
        [ [ second>> ] bi@ + ]
    } 2cleave <duration> ; inline

M: duration time+
    dup timestamp? [ swap time+ ] [ duration+ ] if ;

: duration>years ( duration -- x )
    ! Uses average month/year length since duration loses calendar data
    0 swap
    {
        [ year>> + ]
        [ month>> months-per-year / + ]
        [ day>> days-per-year / + ]
        [ hour>> hours-per-year / + ]
        [ minute>> minutes-per-year / + ]
        [ second>> seconds-per-year / + ]
    } cleave ;

M: duration <=> [ duration>years ] compare ;

: duration>months ( duration -- x ) duration>years months-per-year * ;
: duration>days ( duration -- x ) duration>years days-per-year * ;
: duration>hours ( duration -- x ) duration>years hours-per-year * ;
: duration>minutes ( duration -- x ) duration>years minutes-per-year * ;
: duration>seconds ( duration -- x ) duration>years seconds-per-year * ;
: duration>milliseconds ( duration -- x ) duration>seconds 1000 * ;
: duration>microseconds ( duration -- x ) duration>seconds 1000000 * ;
: duration>nanoseconds ( duration -- x ) duration>seconds 1000000000 * ;

DEFER: time-

: gmt ( timestamp -- timestamp )
    instant >>gmt-offset ; inline

: local-time ( timestamp -- timestamp )
    gmt-offset-duration >>gmt-offset ; inline

: convert-timezone ( timestamp duration -- timestamp )
    [ over gmt-offset>> time- (time+) ] [ >>gmt-offset ] bi ;

: convert-local-time ( timestamp -- timestamp )
    gmt-offset-duration convert-timezone ;

: convert-gmt ( timestamp -- timestamp )
    instant convert-timezone ;

: >local-time ( timestamp -- timestamp' )
    clone convert-local-time ;

: >gmt ( timestamp -- timestamp' )
    clone convert-gmt ;

: >timezone ( timestamp duration -- timestamp' )
    [ clone ] [ convert-timezone ] bi* ;

ALIAS: utc gmt
ALIAS: convert-utc convert-gmt
ALIAS: >utc >gmt

M: timestamp <=> [ >gmt tuple-slots ] compare ;

: same-year? ( ts1 ts2 -- ? )
    [ year>> ] bi@ = ; inline

: quarter ( timestamp -- [1,4] )
    month>> 3 /mod [ drop 1 + ] unless-zero ; inline

: same-quarter? ( ts1 ts2 -- ? )
    {
        [ [ year>> ] same? ]
        [ [ quarter ] same? ]
    } 2&& ;

: same-month? ( ts1 ts2 -- ? )
    {
        [ [ year>> ] same? ]
        [ [ month>> ] same? ]
    } 2&& ;

:: (day-of-year) ( $year $month $day -- n )
    $month cumulative-day-counts nth $day + {
        [ $year leap-year? ]
        [ $month 3 >= ]
    } 0&& [ 1 + ] when ;

: day-of-year ( timestamp -- n )
    >date< (day-of-year) ;

: same-day? ( ts1 ts2 -- ? )
    {
        [ [ year>> ] same? ]
        [ [ month>> ] same? ]
        [ [ day>> ] same? ]
    } 2&& ;

: same-day-of-year? ( ts1 ts2 -- ? )
    {
        [ [ month>> ] same? ]
        [ [ day>> ] same? ]
    } 2&& ;

: (day-of-week) ( year month day -- n )
    ! Zeller Congruence
    ! https://web.textfiles.com/computers/formulas.txt
    ! good for any date since October 15, 1582
    [
        dup 2 <= [ [ 1 - ] [ 12 + ] bi* ] when
        [ dup [ 4 /i + ] [ 100 /i - ] [ 400 /i + ] tri ] dip
        [ 1 + 3 * 5 /i + ] keep 2 * +
    ] dip 1 + + 7 mod ;

: day-of-week ( timestamp -- n )
    >date< (day-of-week) ;

: (week-number) ( timestamp -- [0,53] )
    [ day-of-year ] [ day-of-week [ 7 ] when-zero ] bi - 10 + 7 /i ;

DEFER: end-of-year

: week-number ( timestamp -- [1,53] )
    dup (week-number) {
        {  0 [ year>> 1 - end-of-year (week-number) ] }
        { 53 [ year>> 1 + <year> (week-number) 1 = 1 53 ? ] }
        [ nip ]
    } case ;

: same-week? ( ts1 ts2 -- ? )
    [ [ year>> ] [ week-number ] bi 2array ] same? ;

: same-hour? ( ts1 ts2 -- ? )
    [ >gmt ] bi@ {
        [ [ year>> ] same? ]
        [ [ month>> ] same? ]
        [ [ day>> ] same? ]
        [ [ hour>> ] same? ]
    } 2&& ;

: same-minute? ( ts1 ts2 -- ? )
    [ >gmt ] bi@ {
        [ [ year>> ] same? ]
        [ [ month>> ] same? ]
        [ [ day>> ] same? ]
        [ [ hour>> ] same? ]
        [ [ minute>> ] same? ]
    } 2&& ;

: same-second? ( ts1 ts2 -- ? )
    [ >gmt ] bi@ {
        [ [ second>> floor ] bi@ = ]
        [ same-minute? ]
    } 2&& ;

<PRIVATE

: (time-) ( timestamp timestamp -- n )
    [ [ >date< julian-day-number ] bi@ - 86400 * ]
    [ [ >time< [ 3600 * ] [ 60 * + ] [ + ] tri* ] bi@ - + ]
    [ [ gmt-offset>> duration>seconds ] bi@ swap - + ] 2tri ;

PRIVATE>

GENERIC: time- ( time1 time2 -- time3 )

M: timestamp time-
    ! Exact calendar-time difference
    (time-) seconds ;

: duration* ( obj1 obj2 -- obj3 )
    dup real? [ swap ] when
    dup real? [ * ] [
        {
            [   year>> * ]
            [  month>> * ]
            [    day>> * ]
            [   hour>> * ]
            [ minute>> * ]
            [ second>> * ]
        } 2cleave <duration>
    ] if ;

: before ( duration -- -duration )
    -1 duration* ;

: duration- ( duration1 duration2 -- duration3 )
    {
        [ [ year>> ] bi@ - ]
        [ [ month>> ] bi@ - ]
        [ [ day>> ] bi@ - ]
        [ [ hour>> ] bi@ - ]
        [ [ minute>> ] bi@ - ]
        [ [ second>> ] bi@ - ]
    } 2cleave <duration> ; inline

M: duration time-
    over timestamp? [ before time+ ] [ duration- ] if ;

: unix-1970 ( -- timestamp )
    1970 <year-gmt> ; inline

: millis>timestamp ( x -- timestamp )
    unix-1970 swap 1000 / +second ;

: timestamp>millis ( timestamp -- n )
    unix-1970 (time-) 1000 * >integer ;

: micros>timestamp ( x -- timestamp )
    unix-1970 swap 1000000 / +second ;

: timestamp>micros ( timestamp -- n )
    unix-1970 (time-) 1000000 * >integer ;

: now ( -- timestamp )
    now-gmt gmt-offset-duration [ (time+) ] [ >>gmt-offset ] bi ;

: hence ( duration -- timestamp ) now swap time+ ;
: ago ( duration -- timestamp ) now swap time- ;
: days-since ( time -- n ) ago duration>days ;
: days-until ( time -- n ) now time- duration>days ;

GENERIC: days-in-year ( obj -- n )

M: integer days-in-year leap-year? 366 365 ? ;

M: timestamp days-in-year year>> days-in-year ;

: days-in-month ( timestamp -- n )
    >date< drop (days-in-month) ;

: midnight ( timestamp -- timestamp' ) clone 0 0 0 set-time ; inline
: noon ( timestamp -- timestamp' ) clone 12 0 0 set-time ; inline

: today ( -- timestamp ) now midnight ; inline
: tomorrow ( -- timestamp ) 1 days hence midnight ; inline
: yesterday ( -- timestamp ) 1 days ago midnight ; inline
: overmorrow ( -- timestamp ) 2 days hence midnight ; inline
: ereyesterday ( -- timestamp ) 2 days ago midnight ; inline

: today? ( timestamp -- ? ) now same-day? ; inline
: tomorrow? ( timestamp -- ? ) 1 days hence same-day? ; inline
: yesterday? ( timestamp -- ? ) 1 days ago same-day? ; inline

ALIAS: start-of-day midnight

: end-of-day ( timestamp -- timestamp' )
    clone 23 >>hour 59 >>minute 59+999/1000 >>second ; inline

: first-day-of-month ( timestamp -- timestamp' )
    clone 1 >>day ;

: last-day-of-month ( timestamp -- timestamp' )
    clone dup days-in-month >>day ; inline

: start-of-month ( timestamp -- timestamp' )
    midnight first-day-of-month ; inline

: end-of-month ( timestamp -- timestamp' )
    [ end-of-day ] [ days-in-month ] bi >>day ;

: start-of-quarter ( timestamp -- timestamp' )
    [ start-of-day ] [ quarter 1 - 3 * ] bi >>month ; inline

: end-of-quarter ( timestamp -- timestamp' )
    dup quarter 1 - 3 * 3 + >>month end-of-month ; inline

GENERIC: first-day-of-year ( object -- timestamp )
M: timestamp first-day-of-year clone 1 >>month 1 >>day ;
M: integer first-day-of-year <year> ;

GENERIC: last-day-of-year ( object -- timestamp )
M: timestamp last-day-of-year clone 12 >>month 31 >>day ;
M: integer last-day-of-year 12 31 <date> ;

: first-day-of-decade ( object -- timestamp' )
    first-day-of-year [ dup 10 mod - ] change-year ;

: last-day-of-decade ( object -- timestamp' )
    last-day-of-year [ dup 10 mod - 9 + ] change-year ;

: first-day-of-century ( object -- timestamp' )
    first-day-of-year [ dup 100 mod - ] change-year ;

: last-day-of-century ( object -- timestamp' )
    last-day-of-year [ dup 100 mod - 99 + ] change-year ;

: first-day-of-millennium ( object -- timestamp' )
    first-day-of-year [ dup 1000 mod - ] change-year ;

: last-day-of-millennium ( object -- timestamp' )
    last-day-of-year [ dup 1000 mod - 999 + ] change-year ;

: start-of-year ( object -- timestamp )
    first-day-of-year start-of-day ;

: end-of-year ( object -- timestamp )
    last-day-of-year end-of-day ;

: start-of-decade ( object -- timestamp )
    first-day-of-decade start-of-day ;

: end-of-decade ( object -- timestamp )
    last-day-of-decade end-of-day ;

: end-of-century ( object -- timestamp )
    last-day-of-century end-of-day ;

: start-of-millennium ( object -- timestamp )
    first-day-of-millennium start-of-day ;

: end-of-millennium ( object -- timestamp )
    last-day-of-millennium end-of-day ;

: start-of-hour ( timestamp -- timestamp' ) clone 0 >>minute 0 >>second ;
: end-of-hour ( timestamp -- timestamp' ) clone 59 >>minute 59+999/1000 >>second ;

: start-of-minute ( timestamp -- timestamp' ) clone 0 >>second ;
: end-of-minute ( timestamp -- timestamp' ) clone 59+999/1000 >>second ;

: start-of-second ( timestamp -- timestamp' ) clone [ floor ] change-second ;
: end-of-second ( timestamp -- timestamp' ) clone [ floor 999/1000 + ] change-second ;

<PRIVATE

: day-offset ( timestamp m -- timestamp n )
    over day-of-week - ; inline

: day-this-week ( timestamp n -- timestamp' )
    day-offset days time+ ;

: closest-day ( timestamp n -- timestamp' )
    [ dup day-of-week 7 swap - ] [ + 7 mod ] bi*
    { 0 1 2 3 -3 -2 -1 } nth days time+ ;

:: nth-day-this-month ( $timestamp $n $day -- timestamp' )
    $timestamp clone
    $timestamp start-of-month $day day-this-week
    [ [ month>> ] same? ] guard
    [ $n ] [ $n 1 + ] if weeks time+ ;

PRIVATE>

GENERIC: january ( obj -- timestamp' )
GENERIC: february ( obj -- timestamp' )
GENERIC: march ( obj -- timestamp' )
GENERIC: april ( obj -- timestamp' )
GENERIC: may ( obj -- timestamp' )
GENERIC: june ( obj -- timestamp' )
GENERIC: july ( obj -- timestamp' )
GENERIC: august ( obj -- timestamp' )
GENERIC: september ( obj -- timestamp' )
GENERIC: october ( obj -- timestamp' )
GENERIC: november ( obj -- timestamp' )
GENERIC: december ( obj -- timestamp' )

M: integer january 1 1 <date> ;
M: integer february 2 1 <date> ;
M: integer march 3 1 <date> ;
M: integer april 4 1 <date> ;
M: integer may 5 1 <date> ;
M: integer june 6 1 <date> ;
M: integer july 7 1 <date> ;
M: integer august 8 1 <date> ;
M: integer september 9 1 <date> ;
M: integer october 10 1 <date> ;
M: integer november 11 1 <date> ;
M: integer december 12 1 <date> ;

M: timestamp january clone 1 >>month ;
M: timestamp february clone 2 >>month ;
M: timestamp march clone 3 >>month ;
M: timestamp april clone 4 >>month ;
M: timestamp may clone 5 >>month ;
M: timestamp june clone 6 >>month ;
M: timestamp july clone 7 >>month ;
M: timestamp august clone 8 >>month ;
M: timestamp september clone 9 >>month ;
M: timestamp october clone 10 >>month ;
M: timestamp november clone 11 >>month ;
M: timestamp december clone 12 >>month ;

: closest-sunday ( timestamp -- timestamp' ) 0 closest-day ;
: closest-monday ( timestamp -- timestamp' ) 1 closest-day ;
: closest-tuesday ( timestamp -- timestamp' ) 2 closest-day ;
: closest-wednesday ( timestamp -- timestamp' ) 3 closest-day ;
: closest-thursday ( timestamp -- timestamp' ) 4 closest-day ;
: closest-friday ( timestamp -- timestamp' ) 5 closest-day ;
: closest-saturday ( timestamp -- timestamp' ) 6 closest-day ;

: sunday ( timestamp -- timestamp' ) 0 day-this-week ;
: monday ( timestamp -- timestamp' ) 1 day-this-week ;
: tuesday ( timestamp -- timestamp' ) 2 day-this-week ;
: wednesday ( timestamp -- timestamp' ) 3 day-this-week ;
: thursday ( timestamp -- timestamp' ) 4 day-this-week ;
: friday ( timestamp -- timestamp' ) 5 day-this-week ;
: saturday ( timestamp -- timestamp' ) 6 day-this-week ;

ALIAS: first-day-of-week sunday
ALIAS: last-day-of-week saturday

: day< ( timestamp quot -- timestamp' )
    over clone [ call dup ] dip after=? [ -7 days time+ ] when ; inline
: day<= ( timestamp quot -- timestamp' )
    over clone [ call dup ] dip after? [ -7 days time+ ] when ; inline
: day> ( timestamp quot -- timestamp' )
    over clone [ call dup ] dip before=? [ 7 days time+ ] when ; inline
: day>= ( timestamp quot -- timestamp' )
    over clone [ call dup ] dip before? [ 7 days time+ ] when ; inline

: sunday< ( timestamp -- timestamp' ) [ sunday ] day< ;
: monday< ( timestamp -- timestamp' ) [ monday ] day< ;
: tuesday< ( timestamp -- timestamp' ) [ tuesday ] day< ;
: wednesday< ( timestamp -- timestamp' ) [ wednesday ] day< ;
: thursday< ( timestamp -- timestamp' ) [ thursday ] day< ;
: friday< ( timestamp -- timestamp' ) [ friday ] day< ;
: saturday< ( timestamp -- timestamp' ) [ saturday ] day< ;

: sunday<= ( timestamp -- timestamp' ) [ sunday ] day<= ;
: monday<= ( timestamp -- timestamp' ) [ monday ] day<= ;
: tuesday<= ( timestamp -- timestamp' ) [ tuesday ] day<= ;
: wednesday<= ( timestamp -- timestamp' ) [ wednesday ] day<= ;
: thursday<= ( timestamp -- timestamp' ) [ thursday ] day<= ;
: friday<= ( timestamp -- timestamp' ) [ friday ] day<= ;
: saturday<= ( timestamp -- timestamp' ) [ saturday ] day<= ;

: sunday> ( timestamp -- timestamp' ) [ sunday ] day> ;
: monday> ( timestamp -- timestamp' ) [ monday ] day> ;
: tuesday> ( timestamp -- timestamp' ) [ tuesday ] day> ;
: wednesday> ( timestamp -- timestamp' ) [ wednesday ] day> ;
: thursday> ( timestamp -- timestamp' ) [ thursday ] day> ;
: friday> ( timestamp -- timestamp' ) [ friday ] day> ;
: saturday> ( timestamp -- timestamp' ) [ saturday ] day> ;

: sunday>= ( timestamp -- timestamp' ) [ sunday ] day>= ;
: monday>= ( timestamp -- timestamp' ) [ monday ] day>= ;
: tuesday>= ( timestamp -- timestamp' ) [ tuesday ] day>= ;
: wednesday>= ( timestamp -- timestamp' ) [ wednesday ] day>= ;
: thursday>= ( timestamp -- timestamp' ) [ thursday ] day>= ;
: friday>= ( timestamp -- timestamp' ) [ friday ] day>= ;
: saturday>= ( timestamp -- timestamp' ) [ saturday ] day>= ;

: next-sunday ( timestamp -- timestamp' ) closest-sunday sunday> ;
: next-monday ( timestamp -- timestamp' ) closest-monday monday> ;
: next-tuesday ( timestamp -- timestamp' ) closest-tuesday tuesday> ;
: next-wednesday ( timestamp -- timestamp' ) closest-wednesday wednesday> ;
: next-thursday ( timestamp -- timestamp' ) closest-thursday thursday> ;
: next-friday ( timestamp -- timestamp' ) closest-friday friday> ;
: next-saturday ( timestamp -- timestamp' ) closest-saturday saturday> ;

: last-sunday ( timestamp -- timestamp' ) closest-sunday sunday< ;
: last-monday ( timestamp -- timestamp' ) closest-monday monday< ;
: last-tuesday ( timestamp -- timestamp' ) closest-tuesday tuesday< ;
: last-wednesday ( timestamp -- timestamp' ) closest-wednesday wednesday< ;
: last-thursday ( timestamp -- timestamp' ) closest-thursday thursday< ;
: last-friday ( timestamp -- timestamp' ) closest-friday friday< ;
: last-saturday ( timestamp -- timestamp' ) closest-saturday saturday< ;

: sunday? ( timestamp -- ? ) day-of-week 0 = ;
: monday? ( timestamp -- ? ) day-of-week 1 = ;
: tuesday? ( timestamp -- ? ) day-of-week 2 = ;
: wednesday? ( timestamp -- ? ) day-of-week 3 = ;
: thursday? ( timestamp -- ? ) day-of-week 4 = ;
: friday? ( timestamp -- ? ) day-of-week 5 = ;
: saturday? ( timestamp -- ? ) day-of-week 6 = ;

: january? ( timestamp -- ? ) month>> 1 = ;
: february? ( timestamp -- ? ) month>> 2 = ;
: march? ( timestamp -- ? ) month>> 3  = ;
: april? ( timestamp -- ? ) month>> 4 = ;
: may? ( timestamp -- ? ) month>> 5 = ;
: june? ( timestamp -- ? ) month>> 6 = ;
: july? ( timestamp -- ? ) month>> 7 = ;
: august? ( timestamp -- ? ) month>> 8 = ;
: september? ( timestamp -- ? ) month>> 9 = ;
: october? ( timestamp -- ? ) month>> 10 = ;
: november? ( timestamp -- ? ) month>> 11 = ;
: december? ( timestamp -- ? ) month>> 12 = ;

: weekend? ( timestamp -- ? ) day-of-week { 0 6 } member? ;
: weekday? ( timestamp -- ? ) weekend? not ;

: same-or-next-business-day ( timestamp -- timestamp' )
    dup day-of-week {
        { 0 [ monday ] }
        { 6 [ 2 days time+ ] }
        [ drop ]
    } case ;

: same-or-previous-business-day ( timestamp -- timestamp' )
    dup day-of-week {
        { 0 [ -2 days time+ ] }
        { 6 [ friday ] }
        [ drop ]
    } case ;

: weekdays-between ( date1 date2 -- n )
    [
        [ swap time- duration>days 5 * ]
        [ [ day-of-week ] bi@ - 2 * ] 2bi - 7 /i 1 +
    ] 2keep
    day-of-week 6 = [ [ 1 - ] dip ] when
    day-of-week 0 = [ 1 - ] when ;

: sunday-of-month ( timestamp n -- timestamp' ) 0 nth-day-this-month ;
: monday-of-month ( timestamp n -- timestamp' ) 1 nth-day-this-month ;
: tuesday-of-month ( timestamp n -- timestamp' ) 2 nth-day-this-month ;
: wednesday-of-month ( timestamp n -- timestamp' ) 3 nth-day-this-month ;
: thursday-of-month ( timestamp n -- timestamp' ) 4 nth-day-this-month ;
: friday-of-month ( timestamp n -- timestamp' ) 5 nth-day-this-month ;
: saturday-of-month ( timestamp n -- timestamp' ) 6 nth-day-this-month ;

: last-sunday-of-month ( timestamp -- timestamp' ) last-day-of-month sunday<= ;
: last-monday-of-month ( timestamp -- timestamp' ) last-day-of-month monday<= ;
: last-tuesday-of-month ( timestamp -- timestamp' ) last-day-of-month tuesday<= ;
: last-wednesday-of-month ( timestamp -- timestamp' ) last-day-of-month wednesday<= ;
: last-thursday-of-month ( timestamp -- timestamp' ) last-day-of-month thursday<= ;
: last-friday-of-month ( timestamp -- timestamp' ) last-day-of-month friday<= ;
: last-saturday-of-month ( timestamp -- timestamp' ) last-day-of-month saturday<= ;

: start-of-week ( timestamp -- timestamp' )
    sunday midnight ;

: end-of-week ( timestamp -- timestamp' )
    saturday end-of-day ;

: o'clock ( timestamp n -- timestamp' )
    [ midnight ] dip >>hour ;

: am ( timestamp n -- timestamp' )
    1 12 [a,b] check-interval 12 mod o'clock ;

: pm ( timestamp n -- timestamp' )
    1 12 [a,b] check-interval 12 mod 12 + o'clock ;

: time-since-midnight ( timestamp -- duration )
    instant swap >time< set-time ;

: since-1970 ( duration -- timestamp )
    unix-1970 swap (time+) ; inline

: timestamp>unix-time ( timestamp -- seconds )
    unix-1970 (time-) ; inline

: unix-time>timestamp ( seconds -- timestamp )
    unix-1970 swap +second ; inline

! January and February need a fixup with this algorithm.
! Find a better algorithm.
: ymd>ordinal ( year month day -- ordinal )
    [ leap-year? dup -2 -3 ? ]
    [ dup 3 < [ 12 + ] when [ 1 - 30 * ] [ 1 + .6 * floor ] bi + ]
    [ ] tri* + + >integer
    swap 367 366 ? mod ;

: timestamp>year-dates-gmt ( timestamp -- seq )
    [ year>> 1 1 julian-day-number ] [ days-in-year ] bi
    [ drop ] [ + ] 2bi
    [a..b) [ julian-day-number>date <date-gmt> ] map ;

: year-ordinal>timestamp ( year ordinal -- timestamp )
    [ 1 1 julian-day-number ] dip
    + 1 - julian-day-number>date <date-gmt> ;

GENERIC: weeks-in-week-year ( obj -- n )

M: integer weeks-in-week-year
    { [ 1 1 <date> thursday? ] [ 12 31 <date> thursday? ] } 1|| 53 52 ? ;

M: timestamp weeks-in-week-year
    { [ january 1 >>day thursday? ] [ december 31 >>day thursday? ] } 1|| 53 52 ? ;

! https://gml.noaa.gov/grad/solcalc/solareqns.PDF

<PRIVATE

: fractional-year ( timestamp -- radians )
    [ days-in-year 2pi swap / ]
    [ day-of-year 1 - ]
    [ hour>> 12 - 24 / + * ] tri ;

:: declination ( timestamp -- radians )
    timestamp fractional-year :> γ
    0.006918
    0.399912 γ cos * -
    0.070257 γ sin * +
    0.006758 γ 2 * cos * -
    0.000907 γ 2 * sin * +
    0.002697 γ 3 * cos * -
    0.00148  γ 3 * sin * + ;

:: hour-angle ( timestamp latitude -- degrees )
    timestamp declination :> decl
    latitude deg>rad :> lat
    90.833 deg>rad cos
    lat cos decl cos * /
    lat tan decl tan * -
    acos rad>deg ;

:: equation-of-time ( timestamp -- minutes )
    timestamp fractional-year :> γ
    0.000075
    0.001868 γ cos * +
    0.032077 γ sin * -
    0.014615 γ 2 * cos * -
    0.040849 γ 2 * sin * -
    229.18 * ;

: preserve-gmt-offset ( timestamp quot -- timestamp' )
    '[ >utc @ ] [ gmt-offset>> convert-timezone ] bi ; inline

: (sunrise/sunset) ( timestamp latitude longitude quot -- new-timestamp )
    '[
        [ noon ]
        [ _ hour-angle _ swap @ 4 * ]
        [ equation-of-time ] tri + round >integer minutes time-
    ] preserve-gmt-offset ; inline

PRIVATE>

: sunrise ( timestamp latitude longitude -- new-timestamp )
    [ + ] (sunrise/sunset) ;

: sunset ( timestamp latitude longitude -- new-timestamp )
    [ - ] (sunrise/sunset) ;

: solar-noon ( timestamp longitude -- new-timestamp )
    '[
        [ noon _ 4 * ] [ equation-of-time ] bi + minutes time-
        [ round >integer ] change-second
    ] preserve-gmt-offset ;

{
    { [ os unix? ] [ "calendar.unix" ] }
    { [ os windows? ] [ "calendar.windows" ] }
} cond require

{ "threads" "calendar" } "calendar.threads" require-when
