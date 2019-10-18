! Copyright (C) 2007 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays classes.tuple combinators
combinators.short-circuit kernel locals math math.functions
math.intervals math.order sequences summary system vocabs vocabs.loader
assocs ;
IN: calendar

ERROR: not-in-interval value interval ;

: check-interval ( value interval -- value )
    2dup interval-contains? [ drop ] [ not-in-interval ] if ;

HOOK: gmt-offset os ( -- hours minutes seconds )

HOOK: gmt os ( -- timestamp )

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

CONSTANT: day-counts { 0 31 28 31 30 31 30 31 31 30 31 30 31 }

GENERIC: leap-year? ( obj -- ? )

M: integer leap-year? ( year -- ? )
    dup 100 divisor? 400 4 ? divisor? ;

M: timestamp leap-year? ( timestamp -- ? )
    year>> leap-year? ;

: (days-in-month) ( year month -- n )
    dup 2 = [ drop leap-year? 29 28 ? ] [ nip day-counts nth ] if ;

:: <timestamp> ( year month day hour minute second gmt-offset -- timestamp )
    year
    month 1 12 [a,b] check-interval
    day 1 year month (days-in-month) [a,b] check-interval
    hour 0 23 [a,b] check-interval
    minute 0 59 [a,b] check-interval
    second 0 60 [a,b) check-interval
    gmt-offset timestamp boa ;

M: timestamp clone (clone) [ clone ] change-gmt-offset ;

: gmt-offset-duration ( -- duration )
    0 0 0 gmt-offset <duration> ; inline

: <date> ( year month day -- timestamp )
    0 0 0 gmt-offset-duration <timestamp> ; inline

: <date-gmt> ( year month day -- timestamp )
    0 0 0 instant <timestamp> ; inline

: <year> ( year -- timestamp )
    1 1 <date> ; inline

: <year-gmt> ( year -- timestamp )
    1 1 <date-gmt> ; inline

CONSTANT: average-month 30+5/12
CONSTANT: months-per-year 12
CONSTANT: days-per-year 3652425/10000
CONSTANT: hours-per-year 876582/100
CONSTANT: minutes-per-year 5259492/10
CONSTANT: seconds-per-year 31556952

:: julian-day-number ( year month day -- n )
    ! Returns a composite date number
    ! Not valid before year -4800
    14 month - 12 /i :> a
    year 4800 + a - :> y
    month 12 a * + 3 - :> m

    day 153 m * 2 + 5 /i + 365 y * +
    y 4 /i + y 100 /i - y 400 /i + 32045 - ;

:: julian-day-number>date ( n -- year month day )
    ! Inverse of julian-day-number
    n 32044 + :> a
    4 a * 3 + 146097 /i :> b
    a 146097 b * 4 /i - :> c
    4 c * 3 + 1461 /i :> d
    c 1461 d * 4 /i - :> e
    5 e * 2 + 153 /i :> m

    100 b * d + 4800 -
    m 10 /i + m 3 +
    12 m 10 /i * -
    e 153 m * 2 + 5 /i - 1 + ;

GENERIC: easter ( obj -- obj' )

:: easter-month-day ( year -- month day )
    year 19 mod :> a
    year 100 /mod :> ( b c )
    b 4 /mod :> ( d e )
    b 8 + 25 /i :> f
    b f - 1 + 3 /i :> g
    19 a * b + d - g - 15 + 30 mod :> h
    c 4 /mod :> ( i k )
    32 2 e * + 2 i * + h - k - 7 mod :> l
    a 11 h * + 22 l * + 451 /i :> m

    h l + 7 m * - 114 + 31 /mod 1 + ;

M: integer easter ( year -- timestamp )
    dup easter-month-day <date> ;

M: timestamp easter ( timestamp -- timestamp )
    clone
    dup year>> easter-month-day
    swapd >>day swap >>month ;

: >date< ( timestamp -- year month day )
    [ year>> ] [ month>> ] [ day>> ] tri ;

: >time< ( timestamp -- hour minute second )
    [ hour>> ] [ minute>> ] [ second>> ] tri ;

: years ( x -- duration ) instant swap >>year ;
: months ( x -- duration ) instant swap >>month ;
: days ( x -- duration ) instant swap >>day ;
: weeks ( x -- duration ) 7 * days ;
: hours ( x -- duration ) instant swap >>hour ;
: minutes ( x -- duration ) instant swap >>minute ;
: seconds ( x -- duration ) instant swap >>second ;
: milliseconds ( x -- duration ) 1000 / seconds ;
: microseconds ( x -- duration ) 1000000 / seconds ;
: nanoseconds ( x -- duration ) 1000000000 / seconds ;

<PRIVATE

GENERIC: +year ( timestamp x -- timestamp )
GENERIC: +month ( timestamp x -- timestamp )
GENERIC: +day ( timestamp x -- timestamp )
GENERIC: +hour ( timestamp x -- timestamp )
GENERIC: +minute ( timestamp x -- timestamp )
GENERIC: +second ( timestamp x -- timestamp )

: /rem ( f n -- q r )
    ! q is positive or negative, r is positive from 0 <= r < n
    [ / floor >integer ] 2keep rem ;

: float>whole-part ( float -- int float )
    [ floor >integer ] keep over - ;

: adjust-leap-year ( timestamp -- timestamp )
    dup
    { [ day>> 29 = ] [ month>> 2 = ] [ leap-year? not ] } 1&&
    [ 3 >>month 1 >>day ] when ;

M: integer +year ( timestamp n -- timestamp )
    [ + ] curry change-year adjust-leap-year ;

M: real +year ( timestamp n -- timestamp )
    [ float>whole-part swapd days-per-year * +day swap +year ] unless-zero ;

: months/years ( n -- months years )
    12 /rem [ 1 - 12 ] when-zero swap ; inline

M: integer +month ( timestamp n -- timestamp )
    [ over month>> + months/years [ >>month ] dip +year ] unless-zero ;

M: real +month ( timestamp n -- timestamp )
    [ float>whole-part swapd average-month * +day swap +month ] unless-zero ;

M: integer +day ( timestamp n -- timestamp )
    [
        over >date< julian-day-number + julian-day-number>date
        [ >>year ] [ >>month ] [ >>day ] tri*
    ] unless-zero ;

M: real +day ( timestamp n -- timestamp )
    [ float>whole-part swapd 24 * +hour swap +day ] unless-zero ;

: hours/days ( n -- hours days )
    24 /rem swap ;

M: integer +hour ( timestamp n -- timestamp )
    [ over hour>> + hours/days [ >>hour ] dip +day ] unless-zero ;

M: real +hour ( timestamp n -- timestamp )
    float>whole-part swapd 60 * +minute swap +hour ;

: minutes/hours ( n -- minutes hours )
    60 /rem swap ;

M: integer +minute ( timestamp n -- timestamp )
    [ over minute>> + minutes/hours [ >>minute ] dip +hour ] unless-zero ;

M: real +minute ( timestamp n -- timestamp )
    [ float>whole-part swapd 60 * +second swap +minute ] unless-zero ;

: seconds/minutes ( n -- seconds minutes )
    60 /rem swap >integer ;

M: number +second ( timestamp n -- timestamp )
    [ over second>> + seconds/minutes [ >>second ] dip +minute ] unless-zero ;

: (time+) ( timestamp duration -- timestamp' duration )
    [ second>> +second ] keep
    [ minute>> +minute ] keep
    [ hour>>   +hour   ] keep
    [ day>>    +day    ] keep
    [ month>>  +month  ] keep
    [ year>>   +year   ] keep ; inline

: +slots ( obj1 obj2 quot -- n obj1 obj2 )
    [ bi@ + ] curry 2keep ; inline

PRIVATE>

GENERIC#: time+ 1 ( time1 time2 -- time3 )

M: timestamp time+
    [ clone ] dip (time+) drop ;

M: duration time+
    dup timestamp? [
        swap time+
    ] [
        [ year>> ] +slots
        [ month>> ] +slots
        [ day>> ] +slots
        [ hour>> ] +slots
        [ minute>> ] +slots
        [ second>> ] +slots
        2drop <duration>
    ] if ;

: duration>years ( duration -- x )
    ! Uses average month/year length since duration loses calendar
    ! data
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

GENERIC: time- ( time1 time2 -- time3 )

: convert-timezone ( timestamp duration -- timestamp' )
    over gmt-offset>> over = [ drop ] [
        [ over gmt-offset>> time- time+ ] keep >>gmt-offset
    ] if ;

: >local-time ( timestamp -- timestamp' )
    clone gmt-offset-duration convert-timezone ;

: >gmt ( timestamp -- timestamp' )
    clone dup gmt-offset>> dup instant =
    [ drop ] [
        [ neg +second 0 ] change-second
        [ neg +minute 0 ] change-minute
        [ neg +hour   0 ] change-hour
        [ neg +day    0 ] change-day
        [ neg +month  0 ] change-month
        [ neg +year   0 ] change-year drop
    ] if ;

M: timestamp <=> ( ts1 ts2 -- n )
    [ >gmt tuple-slots ] compare ;

: same-day? ( ts1 ts2 -- ? )
    [ >gmt >date< <date> ] same? ;

: (time-) ( timestamp timestamp -- n )
    [ >gmt ] bi@
    [ [ >date< julian-day-number ] bi@ - 86400 * ] 2keep
    [ >time< [ [ 3600 * ] [ 60 * ] bi* ] dip + + ] bi@ - + ;

M: timestamp time-
    ! Exact calendar-time difference
    (time-) seconds ;

: time* ( obj1 obj2 -- obj3 )
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
    -1 time* ;

<PRIVATE

: -slots ( obj1 obj2 quot -- n obj1 obj2 )
    [ bi@ - ] curry 2keep ; inline

PRIVATE>

M: duration time-
    over timestamp? [
        before time+
    ] [
        [ year>> ] -slots
        [ month>> ] -slots
        [ day>> ] -slots
        [ hour>> ] -slots
        [ minute>> ] -slots
        [ second>> ] -slots
        2drop <duration>
    ] if ;

: unix-1970 ( -- timestamp )
    1970 <year-gmt> ; inline

: millis>timestamp ( x -- timestamp )
    [ unix-1970 ] dip 1000 / +second ;

: timestamp>millis ( timestamp -- n )
    unix-1970 (time-) 1000 * >integer ;

: micros>timestamp ( x -- timestamp )
    [ unix-1970 ] dip 1000000 / +second ;

: timestamp>micros ( timestamp -- n )
    unix-1970 (time-) 1000000 * >integer ;

: now ( -- timestamp )
    gmt gmt-offset-duration (time+) >>gmt-offset ;

: hence ( duration -- timestamp ) now swap time+ ;

: ago ( duration -- timestamp ) now swap time- ;

: zeller-congruence ( year month day -- n )
    ! Zeller Congruence
    ! http://web.textfiles.com/computers/formulas.txt
    ! good for any date since October 15, 1582
    [
        dup 2 <= [ [ 1 - ] [ 12 + ] bi* ] when
        [ dup [ 4 /i + ] [ 100 /i - ] [ 400 /i + ] tri ] dip
        [ 1 + 3 * 5 /i + ] keep 2 * +
    ] dip 1 + + 7 mod ;

GENERIC: days-in-year ( obj -- n )

M: integer days-in-year ( year -- n ) leap-year? 366 365 ? ;
M: timestamp days-in-year ( timestamp -- n ) year>> days-in-year ;

: days-in-month ( timestamp -- n )
    >date< drop (days-in-month) ;

: day-of-week ( timestamp -- n )
    >date< zeller-congruence ;

:: (day-of-year) ( year month day -- n )
    day-counts month head-slice sum day +
    year leap-year? [
        year month day <date>
        year 3 1 <date>
        after=? [ 1 + ] when
    ] when ;

: day-of-year ( timestamp -- n )
    >date< (day-of-year) ;

: midnight ( timestamp -- new-timestamp )
    clone 0 >>hour 0 >>minute 0 >>second ; inline

: noon ( timestamp -- new-timestamp )
    midnight 12 >>hour ; inline

: today ( -- timestamp )
    now midnight ; inline

: tomorrow ( -- timestamp )
    1 days hence midnight ; inline

: yesterday ( -- timestamp )
    1 days ago midnight ; inline

: beginning-of-month ( timestamp -- new-timestamp )
    midnight 1 >>day ; inline

: end-of-month ( timestamp -- new-timestamp )
    [ midnight ] [ days-in-month ] bi >>day ;

<PRIVATE

: day-offset ( timestamp m -- new-timestamp n )
    over day-of-week - ; inline

: day-this-week ( timestamp n -- new-timestamp )
    day-offset days time+ ;

:: nth-day-this-month ( timestamp n day -- new-timestamp )
    timestamp beginning-of-month day day-this-week
    dup timestamp [ month>> ] same? [ 1 weeks time+ ] unless
    n 1 - [ weeks time+ ] unless-zero ;

: last-day-this-month ( timestamp day -- new-timestamp )
    [ 1 months time+ 1 ] dip nth-day-this-month 1 weeks time- ;

PRIVATE>

GENERIC: january ( obj -- timestamp )
GENERIC: february ( obj -- timestamp )
GENERIC: march ( obj -- timestamp )
GENERIC: april ( obj -- timestamp )
GENERIC: may ( obj -- timestamp )
GENERIC: june ( obj -- timestamp )
GENERIC: july ( obj -- timestamp )
GENERIC: august ( obj -- timestamp )
GENERIC: september ( obj -- timestamp )
GENERIC: october ( obj -- timestamp )
GENERIC: november ( obj -- timestamp )
GENERIC: december ( obj -- timestamp )

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

: sunday ( timestamp -- new-timestamp ) 0 day-this-week ;
: monday ( timestamp -- new-timestamp ) 1 day-this-week ;
: tuesday ( timestamp -- new-timestamp ) 2 day-this-week ;
: wednesday ( timestamp -- new-timestamp ) 3 day-this-week ;
: thursday ( timestamp -- new-timestamp ) 4 day-this-week ;
: friday ( timestamp -- new-timestamp ) 5 day-this-week ;
: saturday ( timestamp -- new-timestamp ) 6 day-this-week ;

: sunday? ( timestamp -- ? ) day-of-week 0 = ;
: monday? ( timestamp -- ? ) day-of-week 1 = ;
: tuesday? ( timestamp -- ? ) day-of-week 2 = ;
: wednesday? ( timestamp -- ? ) day-of-week 3 = ;
: thursday? ( timestamp -- ? ) day-of-week 4 = ;
: friday? ( timestamp -- ? ) day-of-week 5 = ;
: saturday? ( timestamp -- ? ) day-of-week 6 = ;

: sunday-of-month ( timestamp n -- new-timestamp ) 0 nth-day-this-month ;
: monday-of-month ( timestamp n -- new-timestamp ) 1 nth-day-this-month ;
: tuesday-of-month ( timestamp n -- new-timestamp ) 2 nth-day-this-month ;
: wednesday-of-month ( timestamp n -- new-timestamp ) 3 nth-day-this-month ;
: thursday-of-month ( timestamp n -- new-timestamp ) 4 nth-day-this-month ;
: friday-of-month ( timestamp n -- new-timestamp ) 5 nth-day-this-month ;
: saturday-of-month ( timestamp n -- new-timestamp ) 6 nth-day-this-month ;

: last-sunday-of-month ( timestamp -- new-timestamp ) 0 last-day-this-month ;
: last-monday-of-month ( timestamp -- new-timestamp ) 1 last-day-this-month ;
: last-tuesday-of-month ( timestamp -- new-timestamp ) 2 last-day-this-month ;
: last-wednesday-of-month ( timestamp -- new-timestamp ) 3 last-day-this-month ;
: last-thursday-of-month ( timestamp -- new-timestamp ) 4 last-day-this-month ;
: last-friday-of-month ( timestamp -- new-timestamp ) 5 last-day-this-month ;
: last-saturday-of-month ( timestamp -- new-timestamp ) 6 last-day-this-month ;

: beginning-of-week ( timestamp -- new-timestamp )
    midnight sunday ;

: o'clock ( timestamp n -- new-timestamp )
    [ midnight ] dip >>hour ;

: am ( timestamp n -- new-timestamp )
    0 12 [a,b] check-interval o'clock ;

: pm ( timestamp n -- new-timestamp )
    0 12 [a,b] check-interval 12 + o'clock ;

GENERIC: beginning-of-year ( object -- new-timestamp )
M: timestamp beginning-of-year beginning-of-month 1 >>month ;
M: integer beginning-of-year <year> ;

GENERIC: end-of-year ( object -- new-timestamp )
M: timestamp end-of-year 12 >>month 31 >>day ;
M: integer end-of-year 12 31 <date> ;

: time-since-midnight ( timestamp -- duration )
    dup midnight time- ; inline

: since-1970 ( duration -- timestamp )
    unix-1970 time+ ; inline

: timestamp>unix-time ( timestamp -- seconds )
    unix-1970 (time-) ; inline

: unix-time>timestamp ( seconds -- timestamp )
    [ unix-1970 ] dip +second ; inline

{
    { [ os unix? ] [ "calendar.unix" ] }
    { [ os windows? ] [ "calendar.windows" ] }
} cond require

{ "threads" "calendar" } "calendar.threads" require-when
