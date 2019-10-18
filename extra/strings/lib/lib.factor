
USING: math arrays sequences ;

IN: strings.lib

: char>digit ( c -- i ) 48 - ;

: string>digits ( s -- seq ) [ char>digit ] { } map-as ;
