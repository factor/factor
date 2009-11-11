! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar kernel math words ;
IN: calendar.holidays.us

<<
SYNTAX: us-federal
    word "us-federal" dup set-word-prop ;
>>

! Federal Holidays
: new-years-day ( timestamp/n -- timestamp )
    january 1 >>day ; us-federal

: martin-luther-king-day ( timestamp/n -- timestamp )
    january 3 monday-of-month ; us-federal

: inauguration-day ( timestamp/n -- timestamp )
    year dup neg 4 rem + january 20 >>day ; us-federal

: washington's-birthday ( timestamp/n -- timestamp )
    february 3 monday-of-month ; us-federal

ALIAS: presidents-day washington's-birthday us-federal

: memorial-day ( timestamp/n -- timestamp )
    may last-monday-of-month ; us-federal

: independence-day ( timestamp/n -- timestamp )
    july 4 >>day ; us-federal

: labor-day ( timestamp/n -- timestamp )
    september 1 monday-of-month ; us-federal

: columbus-day ( timestamp/n -- timestamp )
    october 2 monday-of-month ; us-federal

: veterans'-day ( timestamp/n -- timestamp )
    november 11 >>day ; us-federal

: thanksgiving-day ( timestamp/n -- timestamp )
    november 4 thursday-of-month ; us-federal

: christmas-day ( timestamp/n -- timestamp )
    december 25 >>day ; us-federal

! Other Holidays

: belly-laugh-day ( timestamp/n -- timestamp )
    january 24 >>day ;

: groundhog-day ( timestamp/n -- timestamp )
    february 2 >>day ;

: lincoln's-birthday ( timestamp/n -- timestamp )
    february 12 >>day ;

: valentine's-day ( timestamp/n -- timestamp )
    february 14 >>day ;

: st-patrick's-day ( timestamp/n -- timestamp )
    march 17 >>day ;

: ash-wednesday ( timestamp/n -- timestamp )
    easter 46 days time- ;

ALIAS: first-day-of-lent ash-wednesday

: fat-tuesday ( timestamp/n -- timestamp )
    ash-wednesday 1 days time- ;

: good-friday ( timestamp/n -- timestamp )
    easter 2 days time- ;

: tax-day ( timestamp/n -- timestamp )
    april 15 >>day ;

: earth-day ( timestamp/n -- timestamp )
    april 22 >>day ;

: administrative-professionals'-day ( timestamp/n -- timestamp )
    april last-saturday-of-month wednesday ;

: cinco-de-mayo ( timestamp/n -- timestamp )
    may 5 >>day ;

: mother's-day ( timestamp/n -- timestamp )
    may 2 sunday-of-month ;

: armed-forces-day ( timestamp/n -- timestamp )
    may 3 saturday-of-month ;

: flag-day ( timestamp/n -- timestamp )
    june 14 >>day ;

: parents'-day ( timestamp/n -- timestamp )
    july 4 sunday-of-month ;

: grandparents'-day ( timestamp/n -- timestamp )
    labor-day 1 weeks time+ ;

: patriot-day ( timestamp/n -- timestamp )
    september 11 >>day ;

: stepfamily-day ( timestamp/n -- timestamp )
    september 16 >>day ;

: citizenship-day ( timestamp/n -- timestamp )
    september 17 >>day ;

: boss's-day ( timestamp/n -- timestamp )
    october 16 >>day ;

: sweetest-day ( timestamp/n -- timestamp )
    october 3 saturday-of-month ;

: halloween ( timestamp/n -- timestamp )
    october 31 >>day ;

: election-day ( timestamp/n -- timestamp )
    november 1 monday-of-month 1 days time+ ;

: black-friday ( timestamp/n -- timestamp )
    thanksgiving-day 1 days time+ ;

: pearl-harbor-remembrance-day ( timestamp/n -- timestamp )
    december 7 >>day ;

: new-year's-eve ( timestamp/n -- timestamp )
    december 31 >>day ;
