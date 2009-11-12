! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar combinators.short-circuit fry
kernel lexer math namespaces parser sequences shuffle vocabs
words ;
IN: calendar.holidays.us

SYMBOLS: world us us-federal canada
commonwealth-of-nations ;

<<
SYNTAX: HOLIDAY:
    CREATE-WORD
    dup H{ } clone "holiday" set-word-prop
    parse-definition (( timestamp/n -- timestamp )) define-declared ;

SYNTAX: HOLIDAY-NAME:
    scan-word "holiday" word-prop scan-word scan-object >at drop ;
>>

: holiday>timestamp ( n word -- timestamp )
    execute( timestamp -- timestamp' ) ;

: find-holidays ( n symbol -- seq )
    all-words swap '[ "holiday" word-prop _ swap key? ] filter
    [ holiday>timestamp ] with map ;

: adjust-federal-holiday ( timestamp -- timestamp' )
    dup saturday? [
        1 days time-
    ] [
        dup sunday? [
            1 days time+
        ] when 
    ] if ;

: us-federal-holidays ( timestamp/n -- seq )
    us-federal find-holidays [ adjust-federal-holiday ] map ;

: canadian-holidays ( timestamp/n -- seq )
    canada find-holidays ;

HOLIDAY: new-year's-day january 1 >>day ;
HOLIDAY-NAME: new-year's-day world "New Year's Day"
HOLIDAY-NAME: new-year's-day us-federal "New Year's Day"

HOLIDAY: martin-luther-king-day january 3 monday-of-month ;
HOLIDAY-NAME: martin-luther-king-day us-federal "Martin Luther King Day"

HOLIDAY: inauguration-day year dup 4 neg rem + january 20 >>day ;
HOLIDAY-NAME: inauguration-day us "Inauguration Day"

HOLIDAY: washington's-birthday february 3 monday-of-month ;
HOLIDAY-NAME: washington's-birthday us-federal "Washington's Birthday"

HOLIDAY: memorial-day may last-monday-of-month ;
HOLIDAY-NAME: memorial-day us-federal "Memorial Day"

HOLIDAY: independence-day july 4 >>day ;
HOLIDAY-NAME: independence-day us-federal "Independence Day"

HOLIDAY: labor-day september 1 monday-of-month ;
HOLIDAY-NAME: labor-day us-federal "Labor Day"

HOLIDAY: columbus-day october 2 monday-of-month ;
HOLIDAY-NAME: columbus-day us-federal "Columbus Day"

HOLIDAY: veterans-day november 11 >>day ;
HOLIDAY-NAME: veterans-day us-federal "Veterans Day"
HOLIDAY-NAME: veterans-day world "Armistice Day"
HOLIDAY-NAME: veterans-day commonwealth-of-nations "Remembrance Day"

HOLIDAY: thanksgiving-day november 4 thursday-of-month ;
HOLIDAY-NAME: thanksgiving-day us-federal "Thanksgiving Day"

HOLIDAY: canadian-thanksgiving-day october 2 monday-of-month ;
HOLIDAY-NAME: canadian-thanksgiving-day canada "Thanksgiving Day"

HOLIDAY: christmas-day december 25 >>day ;
HOLIDAY-NAME: christmas-day world "Christmas Day"
HOLIDAY-NAME: christmas-day us-federal "Christmas Day"

HOLIDAY: belly-laugh-day january 24 >>day ;

HOLIDAY: groundhog-day february 2 >>day ;

HOLIDAY: lincoln's-birthday february 12 >>day ;

HOLIDAY: valentine's-day february 14 >>day ;

HOLIDAY: st-patrick's-day march 17 >>day ;

HOLIDAY: ash-wednesday easter 46 days time- ;

ALIAS: first-day-of-lent ash-wednesday

HOLIDAY: fat-tuesday ash-wednesday 1 days time- ;

HOLIDAY: good-friday easter 2 days time- ;

HOLIDAY: tax-day april 15 >>day ;

HOLIDAY: earth-day april 22 >>day ;

HOLIDAY: administrative-professionals'-day april last-saturday-of-month wednesday ;

HOLIDAY: cinco-de-mayo may 5 >>day ;

HOLIDAY: mother's-day may 2 sunday-of-month ;

HOLIDAY: armed-forces-day may 3 saturday-of-month ;

HOLIDAY: flag-day june 14 >>day ;

HOLIDAY: parents'-day july 4 sunday-of-month ;

HOLIDAY: grandparents'-day labor-day 1 weeks time+ ;

HOLIDAY: patriot-day september 11 >>day ;

HOLIDAY: stepfamily-day september 16 >>day ;

HOLIDAY: citizenship-day september 17 >>day ;

HOLIDAY: boss's-day october 16 >>day ;

HOLIDAY: sweetest-day october 3 saturday-of-month ;

HOLIDAY: halloween october 31 >>day ;

HOLIDAY: election-day november 1 monday-of-month 1 days time+ ;

HOLIDAY: black-friday thanksgiving-day 1 days time+ ;

HOLIDAY: pearl-harbor-remembrance-day december 7 >>day ;

HOLIDAY: new-year's-eve december 31 >>day ;

: post-office-open? ( timestamp -- ? )
    {
        [ sunday? not ]
        [ dup us-federal-holidays [ same-day? ] with any? not ]
    } 1&& ;
