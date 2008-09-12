USING: math math.ranges arrays sequences kernel random splitting
strings unicode.case ;
IN: strings.lib

: >Upper ( str -- str )
    dup empty? [ unclip ch>upper prefix ] unless ;

: >Upper-dashes ( str -- str )
    "-" split [ >Upper ] map "-" join ;

: lower-alpha-chars ( -- seq )
    CHAR: a CHAR: z [a,b] ;

: upper-alpha-chars ( -- seq )
    CHAR: A CHAR: Z [a,b] ;

: numeric-chars ( -- seq )
    CHAR: 0 CHAR: 9 [a,b] ;

: alpha-chars ( -- seq )
    lower-alpha-chars upper-alpha-chars append ;

: alphanumeric-chars ( -- seq )
    alpha-chars numeric-chars append ;

: random-alpha-char ( -- ch )
    alpha-chars random ;

: random-alphanumeric-char ( -- ch )
    alphanumeric-chars random ;

: random-alphanumeric-string ( length -- str )
    [ random-alphanumeric-char ] "" replicate-as ;
