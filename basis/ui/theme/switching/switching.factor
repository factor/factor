! Copyright (C) 2016 Nicolas Pénet.
! See https://factorcode.org/license.txt for BSD license.
USING: hashtables kernel namespaces sequences ui.theme ui.theme.base16
ui.theme.wombat vocabs.loader ;
IN: ui.theme.switching

SYMBOL: default-theme?
t default-theme? set-global

: update-style ( style color elt -- )
    '[ _ _ rot ?set-at ] change-global ;

: update-stylesheet ( -- )
    \ update-stylesheet get [ execute( -- ) ] each ;

: switch-theme ( theme -- )
    theme set-global update-stylesheet
    f default-theme? set-global ;

: switch-theme-if-default ( theme -- )
    default-theme? get [
        switch-theme t default-theme? set-global
    ] [ drop ] if ;

: light-mode ( -- ) light-theme switch-theme ;

: dark-mode ( -- ) dark-theme switch-theme ;

: wombat-mode ( -- ) wombat-theme switch-theme ;

: base16-mode ( -- ) base16-theme switch-theme ;
