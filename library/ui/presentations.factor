! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets-presentations
USING: arrays compiler gadgets gadgets-buttons gadgets-labels
gadgets-menus gadgets-outliner gadgets-panes gadgets-theme
generic hashtables inference inspector io jedit kernel lists
memory namespaces parser prettyprint sequences strings styles
words ;

SYMBOL: commands

{ } clone commands global set-hash

: define-command ( class name quot -- )
    3array commands get push ;

: applicable ( object -- seq )
    commands get [ first call ] subset-with ;

: command-quot ( presented quot -- quot )
    [ \ drop , curry , [ pane get pane-call ] % ] [ ] make ;

TUPLE: command-button object ;

: command-menu ( command-button -- )
    command-button-object dup applicable
    [ [ third command-quot ] keep second swons ] map-with
    <menu> show-hand-menu ;

C: command-button ( gadget object -- button )
    [
        set-command-button-object
        [ command-menu ] <roll-button>
    ] keep
    [ set-gadget-delegate ] keep
    dup menu-button-actions ;

M: command-button gadget-help ( button -- string )
    command-button-object dup word? [ synopsis ] [ summary ] if ;

: init-commands ( style gadget -- gadget )
    presented rot assoc [ <command-button> ] when* ;

: style-font ( style -- font )
    [ font swap assoc [ "Monospaced" ] unless* ] keep
    [ font-style swap assoc [ plain ] unless* ] keep
    font-size swap assoc [ 12 ] unless* 3array ;

: <styled-label> ( style text -- label )
    <label> foreground pick assoc over set-label-text
    swap style-font over set-label-font ;

: <presentation> ( style text -- presentation )
    gadget pick assoc
    [ ] [ >r dup dup r> <styled-label> init-commands ] ?if
    outline rot assoc [ <outliner> ] when* ;

: gadget. ( gadget -- )
    gadget swons unit
    "This stream does not support live gadgets"
    swap format terpri ;

[ drop t ] "Prettyprint" [ . ] define-command
[ drop t ] "Describe" [ describe ] define-command
[ drop t ] "Push on data stack" [ ] define-command

[ word? ] "See word" [ see ] define-command
[ word? ] "Word call hierarchy" [ uses. ] define-command
[ word? ] "Word caller hierarchy" [ usage. ] define-command
[ word? ] "Open in jEdit" [ jedit ] define-command
[ word? ] "Reload original source" [ reload ] define-command
[ compound? ] "Annotate with watchpoint" [ watch ] define-command
[ compound? ] "Annotate with breakpoint" [ break ] define-command
[ compound? ] "Annotate with profiling" [ profile ] define-command
[ word? ] "Compile" [ recompile ] define-command
[ word? ] "Infer stack effect" [ unit infer . ] define-command

[ [ gadget? ] is? ] "Display gadget" [ gadget. ] define-command
