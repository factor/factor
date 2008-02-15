USING: math arrays sequences kernel random splitting strings ;
IN: strings.lib

: char>digit ( c -- i ) 48 - ;

: string>digits ( s -- seq ) [ char>digit ] { } map-as ;

: >Upper ( str -- str )
    dup empty? [
        unclip ch>upper 1string swap append
    ] unless ;

: >Upper-dashes ( str -- str )
    "-" split [ >Upper ] map "-" join ;

: lower-alpha-chars ( -- seq )
    26 [ CHAR: a + ] map ;

: upper-alpha-chars ( -- seq )
    26 [ CHAR: A + ] map ;

: numeric-chars ( -- seq )
    10 [ CHAR: 0 + ] map ;

: alpha-chars ( -- seq )
    lower-alpha-chars upper-alpha-chars append ;

: alphanumeric-chars ( -- seq )
    alpha-chars numeric-chars append ;

: random-alpha-char ( -- ch )
    alpha-chars random ;

: random-alphanumeric-char ( -- ch )
    alphanumeric-chars random ;

: random-alphanumeric-string ( length -- str )
    [ drop random-alphanumeric-char ] map "" like ;

