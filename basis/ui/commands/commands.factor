! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs fry help.markup kernel make quotations
sequences splitting tr ui.gestures unicode words ;
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
    { } like command-map boa ;

: commands ( class -- hash )
    dup "commands" word-prop [ ] [
        H{ } clone [ "commands" set-word-prop ] keep
    ] ?if ;

TR: convert-command-name "-" " " ;

: (command-name) ( string -- newstring )
    convert-command-name >title ;

: get-command-at ( group class -- command-map )
    commands at ;

: command-map-row ( gesture command -- seq )
    [
        [ gesture>string , ]
        [
            [ command-name , ]
            [ command-word <$link> , ]
            [ command-description , ]
            tri
        ] bi*
    ] { } make ;

: command-map. ( alist -- )
    [ command-map-row ] { } assoc>map
    { "Shortcut" "Command" "Word" "Notes" }
    [ \ $strong swap ] { } map>assoc prefix
    $table ;

: $command-map ( element -- )
    [ second (command-name) " commands" append $heading ]
    [
        first2 swap get-command-at
        [ blurb>> print-element ] [ commands>> command-map. ] bi
    ] bi ;

: $command ( element -- )
    reverse first3 get-command-at
    commands>> value-at gesture>string
    $snippet ;

: command-gestures ( class -- hash )
    commands values [
        [
            commands>>
            sift-keys
            [ '[ _ invoke-command ] swap ,, ] assoc-each
        ] each
    ] H{ } make ;

: update-gestures ( class -- )
    dup command-gestures set-gestures ;

: define-command-map ( class group blurb pairs -- )
    <command-map>
    swap pick commands set-at
    update-gestures ;

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
