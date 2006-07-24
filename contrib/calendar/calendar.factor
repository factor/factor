USING: arrays errors generic hashtables io kernel math namespaces sequences
    strings ;
USING: prettyprint inspector ;
IN: calendar

TUPLE: timestamp year month day hour minute second gmt-offset ;
TUPLE: dt year month day hour minute second ;

SYMBOL: gmt-offset
global [ 7 gmt-offset set ] bind

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

: default-array ( seq default -- seq )
    #! Pad seq with values from default until they are the same length
    #! useful for default parameters like: (year=1,month=1,day=1)
    #! { 6 } { 1 1 1 } default-array -> { 6 1 1 }
    2dup [ length ] 2apply >= [
        drop clone
    ] [
        2dup [ length ] 2apply swap - over length [ swap - ] keep rot
        <slice> append
    ] if ;

: first6
    #! to compile words
    [ first ] keep
    [ second ] keep
    [ third ] keep
    [ fourth ] keep
    [ 4 swap nth ] keep
    5 swap nth ;

: first7
    #! instead of [ ] each
    [ first6 ] keep 6 swap nth ;

: prepare-timestamp
    #! Default parameters for timestamp, expand on stack
    { 1970 1 1 0 0 0 0 } default-array dup length 7 >
    [ "make-timestamp expects an array up to length 7" throw ] when first7 ;

DEFER: +dt
DEFER: timestamp=
DEFER: seconds

: make-timestamp ( seq -- timestamp )
    #! Default to 1/1/1 0:0:0
    prepare-timestamp <timestamp>
    [ 0 seconds +dt ] keep
    [ timestamp= [ "invalid timestamp" throw ] unless ] keep ;

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
    14 pick - 12 /i a set
    pick 4800 + a get - y set
    over 12 a get * + 3 - m set
    2nip 153 m get * 2 + 5 /i + 365 y get * +
    y get 4 /i + y get 100 /i - y get 400 /i + 32045 - ;

: julian-day-number>date ( n -- year month day )
    #! Inverse of julian-day-number
    32044 + a set 4 a get * 3 + 146097 /i b set a get 146097 b
    get * 4 /i - c set 4 c get * 3 + 1461 /i d set c get 1461 d
    get * 4 /i - e set 5 e get * 2 + 153 /i m set 100 b get * d
    get + 4800 - m get 10 /i + m get 3 + 12 m get 10 /i * - e
    get 153 m get * 2 + 5 /i - 1+ ;

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

: /mod-wrap ( f n -- q r )
    #! q is positive or negative, r is positive from 0 <= r < n
    [ /f floor >bignum ] 2keep
    [ mod ] keep swap dup 0 < [ + ] [ nip ] if ;

: julian-day-number>timestamp ( n -- timestamp )
    julian-day-number>date 0 0 0 0 <timestamp> ;

GENERIC: +year ( timestamp x -- timestamp )
GENERIC: +month ( timestamp x -- timestamp )
GENERIC: +day ( timestamp x -- timestamp )
GENERIC: +hour ( timestamp x -- timestamp )
GENERIC: +minute ( timestamp x -- timestamp )
GENERIC: +second ( timestamp x -- timestamp )

: float>whole-part ( float -- int float )
    [ floor >bignum ] keep dupd swap - ;

: leap-year? ( year -- ? )
    [ 100 mod zero? ] keep over [
        400 mod zero? and
    ] [
        nip 4 mod zero?
    ] if ;

: adjust-leap-year ( timestamp -- timestamp )
    dup date 29 = swap 2 = and swap leap-year? not and [
        dup >r timestamp-year 3 1 r> [ set-date ] keep
    ] when ;

M: integer +year ( timestamp n -- timestamp )
    over timestamp-year + swap [ set-timestamp-year ] keep
    adjust-leap-year ;
M: float +year ( timestamp n -- timestamp )
    float>whole-part rot swap 365.2425 * +day swap +year ;
M: ratio +year ( timestamp n -- timestamp ) >float +year ;

M: integer +month ( timestamp n -- timestamp )
    over timestamp-month + 12 /mod-wrap
    dup 0 = [ drop 12 >r 1- r> ] when pick set-timestamp-month +year ;
M: float +month ( timestamp n -- timestamp )
    float>whole-part rot swap average-month * +day swap +month ;
M: ratio +month ( timestamp n -- timestamp ) >float +month ;

M: integer +day ( timestamp n -- timestamp )
    swap [ date julian-day-number + julian-day-number>timestamp ] keep
    swap >r time r> [ set-time ] keep ;
M: float +day ( timestamp n -- timestamp )
    float>whole-part rot swap 24 * +hour swap +day ;
M: ratio +day ( timestamp n -- timestamp ) >float +day ;

M: integer +hour ( timestamp n -- timestamp )
    over timestamp-hour + 24 /mod-wrap pick set-timestamp-hour +day ;
M: float +hour ( timestamp n -- timestamp )
    float>whole-part rot swap 60 * +minute swap +hour ;
M: ratio +hour ( timestamp n -- timestamp ) >float +hour ;

M: integer +minute ( timestamp n -- timestamp )
    over timestamp-minute + 60 /mod-wrap pick set-timestamp-minute +hour ;
M: float +minute ( timestamp n -- timestamp )
    float>whole-part rot swap 60 * +second swap +minute ; 
M: ratio +minute ( timestamp n -- timestamp ) >float +minute ;

: (+second) ( timestamp n -- timestamp )
    over timestamp-second + 60 /mod-wrap >r >bignum r>
    pick set-timestamp-second +minute ;
M: integer +second ( timestamp n -- timestamp ) (+second) ;
M: ratio +second ( timestamp n -- timestamp ) (+second) ;
M: float +second ( timestamp n -- timestamp ) (+second) ;

GENERIC: +dt ( obj obj -- timestamp )
: (+dt) ( timestamp dt -- timestamp )
    dupd
    [ dt-second +second ] keep
    [ dt-minute +minute ] keep
    [ dt-hour +hour ] keep
    [ dt-day +day ] keep
    [ dt-month +month ] keep
    dt-year +year
    swap timestamp-gmt-offset over set-timestamp-gmt-offset ;

M: dt +dt ( timestamp dt -- timestamp ) (+dt) ;
M: timestamp +dt ( dt timestamp -- timestamp ) swap (+dt) ;

: dt>vec ( dt -- vec ) tuple>array 2 8 rot <slice> ;
: vec>dt ( vec -- dt ) first6 <dt> ;
: +dts ( dt dt -- dt ) [ dt>vec ] 2apply v+ vec>dt ;
: timestamp>vec ( timestamp -- vec ) tuple>array 2 8 rot <slice> ;

: dt>years ( dt -- x )
    dt>vec [ 1 12 365.2425 8765.82 525949.2 31556952.0 ] [ / ] 2map sum ;
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

: now ( -- timestamp ) gmt >local-time ;
: before ( dt -- -dt ) dt>vec [ neg ] map vec>dt ;
: ago ( dt -- timestamp ) before now +dt ;
: from-now ( dt -- timestamp ) now +dt ;

: days-in-year ( year -- n ) leap-year? 366 365 ? ;
: day-counts { 0 31 28 31 30 31 30 31 31 30 31 30 31 } ;
: days-in-month ( year month -- )
    swap leap-year? [
        [ day-counts nth ] keep 2 = [ 1+ ] when
    ] [
        day-counts nth
    ] if ;

! Zeller Congruence
! http://web.textfiles.com/computers/formulas.txt
! good for any date since October 15, 1582
: (day-of-week) ( year month day -- day-of-week )
    >r dup 2 <= [ 12 + >r 1- r> ] when
    >r dup [ 4 /i + ] keep [ 100 /i - ] keep 400 /i + r>
        [ 1+ 3 * 5 /i + ] keep 2 * + r>
    1+ + 7 mod ;

: day-of-week ( timestamp -- n )
    [ timestamp-year ] keep
    [ timestamp-month ] keep
    timestamp-day
    (day-of-week) ;

: (timestamp=) ( timestamp timestamp -- n timestamp timestamp )
    [ timestamp>vec ] 2apply
    [ [ = ] 2map f swap index ] 2keep ;

: timestamp= ( timestamp timestamp -- ? )
    (timestamp=) 2drop -1 = ;

: timestamp> ( timestamp timestamp -- ? )
    (timestamp=) >r >r dup -1 = [
        r> r> 3drop f
    ] [
        r> dupd nth r> rot swap nth >
    ] if ;

: timestamp>= ( timestamp timestamp -- ? )
    [ timestamp> ] 2keep timestamp= or ;
: timestamp< ( timestamp timestamp -- ? )
    [ timestamp> not ] 2keep timestamp= not and ;
: timestamp<= ( timestamp timestamp -- ? )
    [ timestamp< ] 2keep timestamp= or ;

: day-of-year ( timestamp -- n )
    [
        [ timestamp-year leap-year? ] keep
        dup timestamp-year 3 1 3array make-timestamp timestamp>= and 1 0 ?
    ] keep 
    0 swap [ timestamp-month day-counts <slice> sum + ] keep
    timestamp-day + ;

: month>days days-in-month nth ;

: print-day ( n -- )
    unparse dup length 2 < [
        " " write
    ] when write ;

: print-month ( year month -- )
    [ month-names nth write " " write unparse print ] 2keep
    [ 1 (day-of-week) ] 2keep
    days-in-month
    day-abbreviations2 " " join print
    over [ "   " write ] times
    [ [ 1+ print-day ] keep 1+ + 7 mod 0 = [ terpri ] [ " " write ] if ] each-with
    terpri ;

: print-year ( year -- )
    12 [ 1+ print-month terpri ] each-with ;

: timestamp>http-string ( timestamp -- string )
    #! http timestamp format
    #! Example: Tue, 15 Nov 1994 08:12:31 GMT
    >gmt
    [
        dup day-of-week day-abbreviations3 nth write ", " write
        dup timestamp-day unparse write " " write
        dup timestamp-month months-abbreviations nth write " " write
        dup timestamp-year unparse write " " write
        dup timestamp-hour unparse 2 CHAR: 0 pad-left write ":" write
        dup timestamp-minute unparse 2 CHAR: 0 pad-left write ":" write
        dup timestamp-second >fixnum unparse 2 CHAR: 0 pad-left write " GMT" write
    ] string-out ;

