! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays definitions kernel sequences strings
math assocs words generic make quotations splitting
ui.gestures unicode.case unicode.categories tr fry ;
IN: ui.commands

SYMBOL: +nullary+
SYMBOL: +listener+
SYMBOL: +description+

PREDICATE: listener-command < word +listener+ word-prop ;

GENERIC: invoke-command ( target command -- )

GENERIC: command-name ( command -- str )

TUPLE: command-map blurb commands ;

GENERIC: command-description ( command -- str/f )

GENERIC: command-word ( command -- word )

: <command-map> ( blurb commands -- command-map )
    { } like \ command-map boa ;

: commands ( class -- hash )
    dup "commands" word-prop [ ] [
        H{ } clone [ "commands" set-word-prop ] keep
    ] ?if ;

: get-command-at ( group class -- command-map )
    commands at ;

: command-gestures ( class -- hash )
    commands values [
        [
            commands>>
            [ drop ] assoc-filter
            [ '[ _ invoke-command ] swap ,, ] assoc-each
        ] each
    ] H{ } make ;

: update-gestures ( class -- )
    dup command-gestures set-gestures ;

: define-command-map ( class group blurb pairs -- )
    <command-map>
    swap pick commands set-at
    update-gestures ;

TR: convert-command-name "-" " " ;

: (command-name) ( string -- newstring )
    convert-command-name >title ;

M: word command-name ( word -- str )
    name>> 
    "com-" ?head drop "." ?tail drop
    dup first Letter? [ rest ] unless
    (command-name) ;

M: word command-description ( word -- str )
    +description+ word-prop ;

: default-flags ( -- assoc )
    H{ { +nullary+ f } { +listener+ f } { +description+ f } } ;

: define-command ( word hash -- )
    default-flags swap assoc-union
    '[ _ assoc-union ] change-props drop ;

: command-quot ( target command -- quot )
    [ 1quotation ] [ +nullary+ word-prop ] bi
    [ nip ] [ curry ] if ;

M: word invoke-command ( target command -- )
    command-quot call( -- ) ;

M: word command-word ;

M: f invoke-command ( target command -- ) 2drop ;
