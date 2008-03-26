! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays definitions kernel sequences strings math assocs
words generic namespaces assocs quotations splitting
ui.gestures unicode.case unicode.categories ;
IN: ui.commands

SYMBOL: +nullary+
SYMBOL: +listener+
SYMBOL: +description+

PREDICATE: listener-command < word +listener+ word-prop ;

GENERIC: invoke-command ( target command -- )

GENERIC: command-name ( command -- str )

TUPLE: command-map blurb ;

GENERIC: command-description ( command -- str/f )

GENERIC: command-word ( command -- word )

: <command-map> ( blurb commands -- command-map )
    { } like
    { set-command-map-blurb set-delegate }
    \ command-map construct ;

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
    { { CHAR: - CHAR: \s } } substitute >title ;

M: word command-name ( word -- str )
    word-name
    "com-" ?head drop
    dup first Letter? [ 1 tail ] unless
    (command-name) ;

M: word command-description ( word -- str )
    +description+ word-prop ;

: default-flags ( -- assoc )
    H{ { +nullary+ f } { +listener+ f } { +description+ f } } ;

: define-command ( word hash -- )
    default-flags swap union >r word-props r> update ;

: command-quot ( target command -- quot )
    dup 1quotation swap +nullary+ word-prop
    [ nip ] [ curry ] if ;

M: word invoke-command ( target command -- )
    command-quot call ;

M: word command-word ;

M: f invoke-command ( target command -- ) 2drop ;

: command-string ( gesture command -- string )
    [
        command-name %
        gesture>string [ " (" % % ")" % ] when*
    ] "" make ;
