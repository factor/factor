USING: arrays errors generic hashtables io kernel math
namespaces sequences strings prettyprint inspector ;
IN: calendar

TUPLE: timestamp year month day hour minute second gmt-offset ;
TUPLE: dt year month day hour minute second ;

SYMBOL: gmt-offset
7 gmt-offset set-global

: month-names
    {
        "Not a month" "January" "February" "March" "April" "May" "June"
        "July" "August" "September" "October" "November" "December"
    } ;

: months-abbreviations
    {
        "Not a month"
        "Jan" "Feb" "Mar" "Apr" "May" "Jun" "Jul" "Aug" "Sep" "Oct" "Nov" "Dec"
    } ;

: day-names
    {
        "Sunday" "Monday" "Tuesday" "Wednesday" "Thursday" "Friday" "Saturday"
    } ;

: day-abbreviations2 { "Su" "Mo" "Tu" "We" "Th" "Fr" "Sa" } ;
: day-abbreviations3 { "Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat" } ;

: average-month ( -- x )
    #! length of average month in days
    30.41666666666667 ;

: time>array ( dt -- vec ) tuple>array 2 tail ;

: compare-timestamps ( tuple tuple -- n )
    [ time>array ] 2apply <=> ;

SYMBOL: a
SYMBOL: b
SYMBOL: c
SYMBOL: d
SYMBOL: e
SYMBOL: y
SYMBOL: m

: julian-day-number ( year month day -- n )
    #! Returns a composite date number
    #! Not valid before year -4800
    [
        14 pick - 12 /i a set
        pick 4800 + a get - y set
        over 12 a get * + 3 - m set
        2nip 153 m get * 2 + 5 /i + 365 y get * +
        y get 4 /i + y get 100 /i - y get 400 /i + 32045 -
    ] with-scope ;

: julian-day-number>date ( n -- year month day )
    #! Inverse of julian-day-number
    [
        32044 + a set
        4 a get * 3 + 146097 /i b set
        a get 146097 b get * 4 /i - c set
        4 c get * 3 + 1461 /i d set
        c get 1461 d get * 4 /i - e set
        5 e get * 2 + 153 /i m set
        100 b get * d get + 4800 -
        m get 10 /i + m get 3 +
        12 m get 10 /i * -
        e get 153 m get * 2 + 5 /i - 1+
    ] with-scope ;

: set-date ( year month day timestamp -- )
    [ set-timestamp-day ] keep
    [ set-timestamp-month ] keep
    set-timestamp-year ;

: set-time ( hour minute second timestamp -- )
    [ set-timestamp-second ] keep
    [ set-timestamp-minute ] keep
    set-timestamp-hour ;

: date ( timestamp -- year month day )
    [ timestamp-year ] keep
    [ timestamp-month ] keep
    timestamp-day ;

: time ( timestamp -- hour minute second )
    [ timestamp-hour ] keep
    [ timestamp-minute ] keep
    timestamp-second ;

: zero-dt ( -- <dt> ) 0 0 0 0 0 0 <dt> ;
: years ( n -- dt ) zero-dt [ set-dt-year ] keep ;
: months ( n -- dt ) zero-dt [ set-dt-month ] keep ;
: weeks ( n -- dt ) 7 * zero-dt [ set-dt-day ] keep ;
: days ( n -- dt ) zero-dt [ set-dt-day ] keep ;
: hours ( n -- dt ) zero-dt [ set-dt-hour ] keep ;
: minutes ( n -- dt ) zero-dt [ set-dt-minute ] keep ;
: seconds ( n -- dt ) zero-dt [ set-dt-second ] keep ;

: julian-day-number>timestamp ( n -- timestamp )
    julian-day-number>date 0 0 0 0 <timestamp> ;

GENERIC: +year ( timestamp x -- timestamp )
GENERIC: +month ( timestamp x -- timestamp )
GENERIC: +day ( timestamp x -- timestamp )
GENERIC: +hour ( timestamp x -- timestamp )
GENERIC: +minute ( timestamp x -- timestamp )
GENERIC: +second ( timestamp x -- timestamp )

: /rem ( f n -- q r )
    #! q is positive or negative, r is positive from 0 <= r < n
    [ /f floor >bignum ] 2keep rem ;

: float>whole-part ( float -- int float )
    [ floor >bignum ] keep dupd swap - ;

: leap-year? ( year -- ? )
    dup 100 mod zero? 400 4 ? mod zero? ;

: adjust-leap-year ( timestamp -- timestamp )
    dup date 29 = swap 2 = and swap leap-year? not and [
        dup >r timestamp-year 3 1 r> [ set-date ] keep
    ] when ;

M: integer +year ( timestamp n -- timestamp )
    over timestamp-year + swap [ set-timestamp-year ] keep
    adjust-leap-year ;
M: real +year ( timestamp n -- timestamp )
    float>whole-part rot swap 365.2425 * +day swap +year ;

M: integer +month ( timestamp n -- timestamp )
    over timestamp-month + 12 /rem
    dup zero? [ drop 12 >r 1- r> ] when pick set-timestamp-month
    +year ;
M: real +month ( timestamp n -- timestamp )
    float>whole-part rot swap average-month * +day swap +month ;

M: integer +day ( timestamp n -- timestamp )
    swap [
        date julian-day-number + julian-day-number>timestamp
    ] keep swap >r time r> [ set-time ] keep ;
M: real +day ( timestamp n -- timestamp )
    float>whole-part rot swap 24 * +hour swap +day ;

M: integer +hour ( timestamp n -- timestamp )
    over timestamp-hour + 24 /rem pick set-timestamp-hour
    +day ;
M: real +hour ( timestamp n -- timestamp )
    float>whole-part rot swap 60 * +minute swap +hour ;

M: integer +minute ( timestamp n -- timestamp )
    over timestamp-minute + 60 /rem pick
    set-timestamp-minute +hour ;
M: real +minute ( timestamp n -- timestamp )
    float>whole-part rot swap 60 * +second swap +minute ; 

M: number +second ( timestamp n -- timestamp )
    over timestamp-second + 60 /rem >r >bignum r>
    pick set-timestamp-second +minute ;

: +dt ( timestamp dt -- timestamp )
    dupd
    [ dt-second +second ] keep
    [ dt-minute +minute ] keep
    [ dt-hour +hour ] keep
    [ dt-day +day ] keep
    [ dt-month +month ] keep
    dt-year +year
    swap timestamp-gmt-offset over set-timestamp-gmt-offset ;

: make-timestamp ( year month day hour minute second gmt-offset -- timestamp )
    <timestamp> [ 0 seconds +dt ] keep
    [ = [ "invalid timestamp" throw ] unless ] keep ;

: array>dt ( vec -- dt ) { dt f } swap append >tuple ;
: +dts ( dt dt -- dt ) [ time>array ] 2apply v+ array>dt ;

: dt>years ( dt -- x )
    #! Uses average month/year length since dt loses calendar
    #! data
    time>array
    { 1 12 365.2425 8765.82 525949.2 31556952.0 }
    [ / ] 2map sum ;
: dt>months ( dt -- x ) dt>years 12 * ;
: dt>days ( dt -- x ) dt>years 365.2425 * ;
: dt>hours ( dt -- x ) dt>years 8765.82 * ;
: dt>minutes ( dt -- x ) dt>years 525949.2 * ;
: dt>seconds ( dt -- x ) dt>years 31556952 * ;

: convert-timezone ( timestamp n -- timestamp )
    [ over timestamp-gmt-offset - hours +dt ] keep
    over set-timestamp-gmt-offset ;

: >local-time ( timestamp -- timestamp )
    gmt-offset get convert-timezone ;

: >gmt ( timestamp -- timestamp )
    0 convert-timezone ;

: gmt ( -- timestamp )
    #! GMT time, right now
    1970 1 1 0 0 0 0 <timestamp> millis 1000 /f seconds +dt ; 

: timestamp- ( timestamp timestamp -- dt )
    [ >gmt time>array ] 2apply v- array>dt ;

: now ( -- timestamp ) gmt >local-time ;
: before ( dt -- -dt ) time>array [ neg ] map array>dt ;
: from-now ( dt -- timestamp ) now swap +dt ;
: ago ( dt -- timestamp ) before from-now ;

: days-in-year ( year -- n ) leap-year? 366 365 ? ;
: day-counts { 0 31 28 31 30 31 30 31 31 30 31 30 31 } ;
: days-in-month ( year month -- n )
    swap leap-year? [
        [ day-counts nth ] keep 2 = [ 1+ ] when
    ] [
        day-counts nth
    ] if ;

: zeller-congruence ( year month day -- n )
    #! Zeller Congruence
    #! http://web.textfiles.com/computers/formulas.txt
    #! good for any date since October 15, 1582
    >r dup 2 <= [ 12 + >r 1- r> ] when
    >r dup [ 4 /i + ] keep [ 100 /i - ] keep 400 /i + r>
        [ 1+ 3 * 5 /i + ] keep 2 * + r>
    1+ + 7 mod ;

: day-of-week ( timestamp -- n )
    [ timestamp-year ] keep
    [ timestamp-month ] keep
    timestamp-day
    zeller-congruence ;

: day-of-year ( timestamp -- n )
    [
        [ timestamp-year leap-year? ] keep
        [ date 3array ] keep timestamp-year 3 1 3array <=>
        0 >= and 1 0 ?
    ] keep 
    [ timestamp-month day-counts swap head-slice sum + ] keep
    timestamp-day + ;

: print-day ( n -- )
    number>string dup length 2 < [ bl ] when write ;

: print-month ( year month -- )
    [ month-names nth write bl . ] 2keep
    [ 1 zeller-congruence ] 2keep
    days-in-month day-abbreviations2 " " join print
    over [ "   " write ] times
    [
        [ 1+ print-day ] keep
        1+ + 7 mod zero? [ terpri ] [ bl ] if
    ] each-with terpri ;

: print-year ( year -- )
    12 [ 1+ print-month terpri ] each-with ;

: timestamp>http-string ( timestamp -- string )
    #! http timestamp format
    #! Example: Tue, 15 Nov 1994 08:12:31 GMT
    >gmt
    [
        dup day-of-week day-abbreviations3 nth write ", " write
        dup timestamp-day unparse write bl
        dup timestamp-month months-abbreviations nth write bl
        dup timestamp-year unparse write bl
        dup timestamp-hour unparse 2 CHAR: 0 pad-left write ":" write
        dup timestamp-minute unparse 2 CHAR: 0 pad-left write ":" write
        timestamp-second >fixnum unparse 2 CHAR: 0 pad-left write " GMT" write
    ] string-out ;
