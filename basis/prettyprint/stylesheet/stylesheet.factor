! Copyright (C) 2009 Your name.
! See http://factorcode.org/license.txt for BSD license.
USING: colors.constants hashtables io.styles kernel namespaces
words words.symbol ;
IN: prettyprint.stylesheet

: word-style ( word -- style )
    dup "word-style" word-prop >hashtable [
        [
            [ presented set ] [
                [ parsing-word? ] [ delimiter? ] [ symbol? ] tri
                or or [ COLOR: DarkSlateGray ] [ COLOR: black ] if
                foreground set
            ] bi
        ] bind
    ] keep ;

: string-style ( obj -- style )
    [
        presented set
        COLOR: LightSalmon4 foreground set
    ] H{ } make-assoc ;

: vocab-style ( vocab -- style )
    [
        presented set
        COLOR: cornsilk4 foreground set
    ] H{ } make-assoc ;

: effect-style ( effect -- style )
    [
        presented set
        COLOR: DarkGreen foreground set
    ] H{ } make-assoc ;