USING: math arrays sequences kernel splitting strings ;
IN: strings.lib

: char>digit ( c -- i ) 48 - ;

: string>digits ( s -- seq ) [ char>digit ] { } map-as ;

: >Upper ( str -- str )
    dup empty? [
        unclip ch>upper 1string swap append
    ] unless ;

: >Upper-dashes ( str -- str )
    "-" split [ >Upper ] map "-" join ;
