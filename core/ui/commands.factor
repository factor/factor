! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions kernel sequences strings math assocs
words generic namespaces assocs help quotations ;
IN: gadgets

SYMBOL: +nullary+
SYMBOL: +listener+
SYMBOL: +description+

GENERIC: in-listener? ( command -- ? )

GENERIC: invoke-command ( target command -- )

GENERIC: command-name ( command -- str )

TUPLE: command-map blurb ;

GENERIC: command-description ( command -- str/f )

GENERIC: command-word ( command -- word )

C: command-map ( blurb commands -- command-map )
    swap { } like over set-delegate
    [ set-command-map-blurb ] keep ;

: commands ( class -- hash )
    dup "commands" word-prop [ ] [
        H{ } clone [ "commands" set-word-prop ] keep
    ] ?if ;

: command-map ( group class -- command-map )
    commands at ;

: command-gestures ( class -- hash )
    commands values [
        [
            [ first ] subset
            [ [ invoke-command ] curry swap set ] assoc-each
        ] each
    ] H{ } make-assoc ;

: update-gestures ( class -- )
    dup command-gestures "gestures" set-word-prop ;

: define-command-map ( class group blurb pairs -- )
    <command-map>
    swap pick commands set-at
    update-gestures ;

: (command-name) ( string -- newstring )
    "-" split " " join unclip ch>upper add* ;

M: word command-name ( word -- str )
    word-name
    "com-" ?head drop
    dup first Letter? [ 1 tail ] unless
    (command-name) ;

M: word command-description ( word -- str )
    +description+ word-prop ;

: command-map-row
    [
        dup first gesture>string ,
        second dup command-name ,
        dup command-word \ $link swap 2array ,
        command-description ,
    ] [ ] make ;

: command-map. ( command-map -- )
    [ command-map-row ] map
    { "Shortcut" "Command" "Word" "Notes" }
    [ \ $strong swap ] { } map>assoc add*
    $table ;

: $command-map ( element -- )
    first2
    dup (command-name) " commands" append $heading
    swap command-map
    dup command-map-blurb print-element command-map. ;

: $command ( element -- )
    reverse first3 command-map value-at gesture>string $snippet ;

: define-command ( word hash -- )
    >r word-props r> update ;

: command-quot ( target command -- quot )
    dup 1quotation swap +nullary+ word-prop
    [ nip ] [ curry ] if ;

M: word in-listener? +listener+ word-prop ;

M: word command-word ;

M: f invoke-command ( target command -- ) 2drop ;

: command-string ( gesture command -- string )
    [
        command-name %
        gesture>string [ " (" % % ")" % ] when*
    ] "" make ;
