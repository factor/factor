USING: arrays calendar errors kernel test ;

[ { 1970 1 1 0 0 0 0 } ] [ { } { 1970 1 1 0 0 0 0 } default-array ] unit-test
[ { 2006 1 1 0 0 0 0 } ] [ { 2006 } { 1970 1 1 0 0 0 0 } default-array ] unit-test

[ "invalid timestamp" ] [ [ 2004 12 32 3array make-timestamp ] catch ] unit-test
[ "invalid timestamp" ] [ [ 2004 2 30 3array make-timestamp ] catch ] unit-test
[ "invalid timestamp" ] [ [ 2003 2 29 3array make-timestamp ] catch ] unit-test
[ "invalid timestamp" ] [ [ 2004 -2 9 3array make-timestamp ] catch ] unit-test
[ "invalid timestamp" ] [ [ 2004 12 0 3array make-timestamp ] catch ] unit-test
[ "invalid timestamp" ] [ [ { 2004 12 1 24 } make-timestamp ] catch ] unit-test
[ "invalid timestamp" ] [ [ { 2004 12 1 23 60 } make-timestamp ] catch ] unit-test
[ "invalid timestamp" ] [ [ { 2004 12 1 23 59 60 } make-timestamp ] catch ] unit-test

[ f ] [ 1900 leap-year? ] unit-test
[ t ] [ 1904 leap-year? ] unit-test
[ t ] [ 2000 leap-year? ] unit-test
[ f ] [ 2001 leap-year? ] unit-test
[ f ] [ 2006 leap-year? ] unit-test

[ t ] [ 2006 10 10 0 0 0 0 <timestamp> 1 seconds +dt
        2006 10 10 0 0 1 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 10 10 0 0 0 0 <timestamp> 100 seconds +dt
        2006 10 10 0 1 40 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 10 10 0 0 0 0 <timestamp> -100 seconds +dt
        2006 10 9 23 58 20 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 10 10 0 0 0 0 <timestamp> 86400 seconds +dt
        2006 10 11 0 0 0 0 <timestamp> timestamp= ] unit-test

[ t ] [ 2006 10 10 0 0 0 0 <timestamp> 10 minutes +dt
        2006 10 10 0 10 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 10 10 0 0 0 0 <timestamp> 10.5 minutes +dt
        2006 10 10 0 10 30 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 10 10 0 0 0 0 <timestamp> 3/4 minutes +dt
        2006 10 10 0 0 45 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 10 10 0 0 0 0 <timestamp> -3/4 minutes +dt
        2006 10 9 23 59 15 0 <timestamp> timestamp= ] unit-test

[ t ] [ 2006 10 10 0 0 0 0 <timestamp> 7200 minutes +dt
        2006 10 15 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 10 10 0 0 0 0 <timestamp> -10 minutes +dt
        2006 10 9 23 50 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 10 10 0 0 0 0 <timestamp> -100 minutes +dt
        2006 10 9 22 20 0 0 <timestamp> timestamp= ] unit-test

[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 1 hours +dt
        2006 1 1 1 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 24 hours +dt
        2006 1 2 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> -24 hours +dt
        2005 12 31 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 12 hours +dt
        2006 1 1 12 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 72 hours +dt
        2006 1 4 0 0 0 0 <timestamp> timestamp= ] unit-test

[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 1 days +dt
        2006 1 2 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> -1 days +dt
        2005 12 31 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 365 days +dt
        2007 1 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> -365 days +dt
        2005 1 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2004 1 1 0 0 0 0 <timestamp> 365 days +dt
        2004 12 31 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2004 1 1 0 0 0 0 <timestamp> 366 days +dt
        2005 1 1 0 0 0 0 <timestamp> timestamp= ] unit-test

[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 11 months +dt
        2006 12 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 12 months +dt
        2007 1 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 24 months +dt
        2008 1 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 13 months +dt
        2007 2 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 1 months +dt
        2006 2 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 0 months +dt
        2006 1 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> -1 months +dt
        2005 12 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> -2 months +dt
        2005 11 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> -13 months +dt
        2004 12 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> -24 months +dt
        2004 1 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2004 2 29 0 0 0 0 <timestamp> 12 months +dt
        2005 3 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2004 2 29 0 0 0 0 <timestamp> -12 months +dt
        2003 3 1 0 0 0 0 <timestamp> timestamp= ] unit-test

[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 0 years +dt
        2006 1 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> 1 years +dt
        2007 1 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> -1 years +dt
        2005 1 1 0 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2006 1 1 0 0 0 0 <timestamp> -100 years +dt
        1906 1 1 0 0 0 0 <timestamp> timestamp= ] unit-test
! [ t ] [ 2004 2 29 0 0 0 0 <timestamp> -1 years +dt
        ! 2003 2 28 0 0 0 0 <timestamp> timestamp= ] unit-test

[ 5 ] [ 2006 7 14 0 0 0 0 <timestamp> day-of-week ] unit-test

[ f ] [ 2006 7 14 0 0 0 0 <timestamp> dup timestamp> ] unit-test
[ f ] [ 2006 7 14 0 0 0 0 <timestamp> dup timestamp< ] unit-test
[ t ] [ 2006 7 14 0 0 0 0 <timestamp> dup timestamp>= ] unit-test
[ t ] [ 2006 7 14 0 0 0 0 <timestamp> dup timestamp<= ] unit-test
[ t ] [ 2006 7 14 0 0 0 0 <timestamp> dup timestamp= ] unit-test

[ t ] [ 2006 7 14 [ julian-day-number julian-day-number>date 3array make-timestamp ] 3keep 3array make-timestamp timestamp= ] unit-test

[ 1 ] [ 2006 1 1 3array make-timestamp day-of-year ] unit-test
[ 60 ] [ 2004 2 29 3array make-timestamp day-of-year ] unit-test
[ 61 ] [ 2004 3 1 3array make-timestamp day-of-year ] unit-test
[ 366 ] [ 2004 12 31 3array make-timestamp day-of-year ] unit-test
[ 365 ] [ 2003 12 31 3array make-timestamp day-of-year ] unit-test
[ 60 ] [ 2003 3 1 3array make-timestamp day-of-year ] unit-test

[ t ] [ 2004 12 31 3array make-timestamp dup timestamp= ] unit-test
[ t ] [ 2004 1 1 0 0 0 0 <timestamp> 10 seconds 5 years +dts +dt
        2009 1 1 0 0 10 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2004 1 1 0 0 0 0 <timestamp> -10 seconds -5 years +dts +dt
        1998 12 31 23 59 50 0 <timestamp> timestamp= ] unit-test

[ t ] [ 2004 1 1 23 0 0 12 <timestamp> 0 convert-timezone
        2004 1 1 11 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2004 1 1 5 0 0 -11 <timestamp> 0 convert-timezone
        2004 1 1 16 0 0 0 <timestamp> timestamp= ] unit-test
[ t ] [ 2004 1 1 23 0 0 9.5 <timestamp> 0 convert-timezone
        2004 1 1 13 30 0 0 <timestamp> timestamp= ] unit-test

