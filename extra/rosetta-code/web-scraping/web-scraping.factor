! Copyright (c) 2012 Anonymous
! See https://factorcode.org/license.txt for BSD license.
USING: http.client io kernel math sequences ;
IN: rosetta-code.web-scraping

! https://rosettacode.org/wiki/Web_scraping

! Create a program that downloads the time from this URL:
! https://tycho.usno.navy.mil/cgi-bin/timer.pl and then prints the
! current UTC time by extracting just the UTC time from the web
! page's HTML.

! If possible, only use libraries that come at no extra monetary
! cost with the programming language and that are widely available
! and popular such as CPAN for Perl or Boost for C++.

: web-scraping-main ( -- )
    "https://tycho.usno.navy.mil/cgi-bin/timer.pl" http-get nip
    [ "UTC" subseq-index [ 9 - ] [ 1 - ] bi ] keep subseq print ;

MAIN: web-scraping-main
