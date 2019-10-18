! (c)2008 Joe Groff, see BSD license etc.
USING: kernel accessors assocs
sequences sequences.n-based tools.test ;
IN: sequences.n-based.tests

: months ( -- assoc )
    V{
        "January"
        "February"
        "March"
        "April"
        "May"
        "June"
        "July"
        "August"
        "September"
        "October"
        "November"
        "December"
    } clone 1 <n-based-assoc> ; inline

[ "December" t ]
[ 12 months at* ] unit-test 
[ f f ]
[ 13 months at* ] unit-test 
[ f f ]
[ 0 months at* ] unit-test 

[ 12 ] [ months assoc-size ] unit-test

[ {
    {  1 "January" }
    {  2 "February" }
    {  3 "March" }
    {  4 "April" }
    {  5 "May" }
    {  6 "June" }
    {  7 "July" }
    {  8 "August" }
    {  9 "September" }
    { 10 "October" }
    { 11 "November" }
    { 12 "December" }
} ] [ months >alist ] unit-test

[ V{
    "January"
    "February"
    "March"
    "April"
    "May"
    "June"
    "July"
    "August"
    "September"
    "October"
    "November"
    "December"
    "Smarch"
} ] [ "Smarch" 13 months [ set-at ] keep seq>> ] unit-test

[ V{ } ] [ months [ clear-assoc ] keep seq>> ] unit-test


