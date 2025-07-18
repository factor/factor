! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar calendar.holidays
calendar.holidays.private calendar.holidays.world
calendar.private combinators combinators.short-circuit kernel
math sequences ;
IN: calendar.holidays.us

SINGLETONS: us us-federal us-market ;

HOLIDAY: new-years-day january 1 >>day ;
HOLIDAY-NAME: new-years-day world "New Year's Day"
HOLIDAY-NAME: new-years-day us-federal "New Year's Day"
HOLIDAY-NAME: new-years-day us-market "New Year's Day"

<PRIVATE

: adjust-federal-holiday ( timestamp -- timestamp )
    {
        ! Don't adjust to Dec 31
        { [ dup { [ dup new-years-day same-day? ] [ saturday? ] } 1&& ] [ ] }
        { [ dup saturday? ] [ -1 days (time+) ] }
        { [ dup sunday? ] [ 1 days (time+) ] }
        [ ]
    } cond ;

PRIVATE>

: adjust-federal-holidays ( timestamp seq -- seq' )
    [
        [ clone ] dip execute( timestamp -- timestamp ) adjust-federal-holiday
    ] with map ;

M: us-federal holidays
    (holidays) adjust-federal-holidays ;

M: us-market holidays
    (holidays) adjust-federal-holidays ;

: us-post-office-open? ( timestamp -- ? )
    { [ sunday? not ] [ us-federal holiday? not ] } 1&& ;

HOLIDAY: martin-luther-king-day january 2 monday-of-month ;
HOLIDAY-NAME: martin-luther-king-day us-federal "Martin Luther King Day"
HOLIDAY-NAME: martin-luther-king-day us-market "Martin Luther King Day"

HOLIDAY: inauguration-day january 20 >>day [ dup 4 neg rem + ] change-year ;
HOLIDAY-NAME: inauguration-day us "Inauguration Day"

HOLIDAY: washingtons-birthday february 2 monday-of-month ;
HOLIDAY-NAME: washingtons-birthday us-market "Washington's Birthday"

HOLIDAY: good-friday easter 2 days time- ;
HOLIDAY-NAME: good-friday us-market "Good Friday"

HOLIDAY: presidents-day february 2 monday-of-month ;
HOLIDAY-NAME: presidents-day us-federal "President's Day"

HOLIDAY: memorial-day may last-monday-of-month ;
HOLIDAY-NAME: memorial-day us-federal "Memorial Day"
HOLIDAY-NAME: memorial-day us-market "Memorial Day"

HOLIDAY: juneteenth-national-independence-day june 19 >>day ;
HOLIDAY-NAME: juneteenth-national-independence-day us-federal "Juneteenth National Independence Day"
HOLIDAY-NAME: juneteenth-national-independence-day us-market "Juneteenth National Independence Day"

HOLIDAY: independence-day july 4 >>day ;
HOLIDAY-NAME: independence-day us-federal "Independence Day"
HOLIDAY-NAME: independence-day us-market "Independence Day"

HOLIDAY: labor-day september 0 monday-of-month ;
HOLIDAY-NAME: labor-day us-federal "Labor Day"
HOLIDAY-NAME: labor-day us-market "Labor Day"

HOLIDAY: columbus-day october 1 monday-of-month ;
HOLIDAY-NAME: columbus-day us-federal "Columbus Day"

HOLIDAY-NAME: armistice-day us-federal "Veterans Day"

HOLIDAY: thanksgiving-day november 3 thursday-of-month ;
HOLIDAY-NAME: thanksgiving-day us-federal "Thanksgiving Day"
HOLIDAY-NAME: thanksgiving-day us-market "Thanksgiving Day"

HOLIDAY: christmas-day december 25 >>day ;
HOLIDAY-NAME: christmas-day world "Christmas Day"
HOLIDAY-NAME: christmas-day us-federal "Christmas Day"
HOLIDAY-NAME: christmas-day us-market "Christmas Day"

HOLIDAY: belly-laugh-day january 24 >>day ;

HOLIDAY: groundhog-day february 2 >>day ;

HOLIDAY: lincolns-birthday february 12 >>day ;

HOLIDAY: valentines-day february 14 >>day ;

HOLIDAY: st-patricks-day march 17 >>day ;

HOLIDAY: ash-wednesday easter 46 days time- ;

ALIAS: first-day-of-lent ash-wednesday

HOLIDAY: fat-tuesday ash-wednesday 1 days time- ;

HOLIDAY: tax-day april 15 >>day ;

HOLIDAY: earth-day april 22 >>day ;

HOLIDAY: administrative-professionals-day april last-saturday-of-month wednesday ;

HOLIDAY: cinco-de-mayo may 5 >>day ;

HOLIDAY: mothers-day may 1 sunday-of-month ;

HOLIDAY: armed-forces-day may 2 saturday-of-month ;

HOLIDAY: national-donut-day june 0 friday-of-month ;

HOLIDAY: flag-day june 14 >>day ;

HOLIDAY: parents-day july 3 sunday-of-month ;

HOLIDAY: grandparents-day labor-day 1 weeks time+ ;

HOLIDAY: patriot-day september 11 >>day ;

HOLIDAY: stepfamily-day september 16 >>day ;

HOLIDAY: citizenship-day september 17 >>day ;

HOLIDAY: bosss-day october 16 >>day ;

HOLIDAY: sweetest-day october 2 saturday-of-month ;

HOLIDAY: halloween october 31 >>day ;

HOLIDAY: election-day november 0 monday-of-month 1 days time+ ;

HOLIDAY: black-friday thanksgiving-day 1 days time+ ;

HOLIDAY: pearl-harbor-remembrance-day december 7 >>day ;

HOLIDAY: new-years-eve december 31 >>day ;
