! Copyright (C) 2016 Nicolas Pénet.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors skov.basis.code.execution combinators.smart help.topics
kernel locals models ui.gadgets skov.basis.ui.gadgets.buttons.round
ui.gadgets.packs skov.basis.ui.tools.environment.theme vocabs words ;
IN: skov.basis.ui.gadgets.buttons.activate

: vocab/word? ( obj -- ? )
    [ vocab? ] [ [ link? ] [ name>> word? ] [ drop f ] smart-if ] bi or ;

: vocab-name ( obj -- str )
    name>> [ word? ] [ vocabulary>> ] smart-when ;

:: <activate-button> ( model -- gadget )
    model value>> vocab-name :> name
    name interactive?
    [ blue-background "Active"
      [ drop name remove-interactive-vocab model notify-connections ]
      <round-button> "Deactivate this vocabulary" >>tooltip ]
    [ dark-background "Inactive"
      [ drop name add-interactive-vocab model notify-connections ]
      <round-button> "Activate this vocabulary" >>tooltip ] if ;

TUPLE: active/inactive < pack ;

: <active/inactive> ( model -- gadget )
    active/inactive new swap >>model ;

M: active/inactive model-changed
    dup clear-gadget swap
    [ value>> vocab/word? ] [ <activate-button> add-gadget ] smart-when* drop ;
