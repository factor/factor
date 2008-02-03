USING: math arrays sequences kernel splitting strings ;
IN: strings.lib

! : char>digit ( c -- i ) 48 - ;

! : string>digits ( s -- seq ) [ char>digit ] { } map-as ;
