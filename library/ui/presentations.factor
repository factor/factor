! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables inspector io jedit kernel lists memory
namespaces parser prettyprint sequences styles vectors words ;

SYMBOL: commands

global [ 100 <vector> commands set ] bind

: define-command ( class name quot -- )
    3list commands get push ;

: applicable ( object -- )
    commands get >list
    [ car call ] subset-with ;

DEFER: pane-call

: command-menu ( pane -- menu )
    presented get dup applicable [
        3dup third [
            [ swap literal, % ] make-list , ,
            [ pane-call drop ] %
        ] make-list >r second r> cons
    ] map 2nip ;

: init-commands ( gadget pane -- )
    over presented paint-prop [
        [ drop ] swap
        unit
        [ command-menu <menu> show-menu ] append3
        button-gestures
    ] [
        2drop
    ] ifte ;

: <styled-label> ( style text -- label )
    <label> swap alist>hash over set-gadget-paint ;

: <presentation> ( style text pane -- presentation )
    pick gadget swap assoc dup [
        >r 3drop r>
    ] [
        drop >r <styled-label> dup r> init-commands
    ] ifte ;

: gadget. ( gadget -- )
    gadget swons unit "" swap write-attr ;

[ drop t ] "Prettyprint" [ prettyprint ] define-command
[ drop t ] "Inspect" [ inspect ] define-command
[ drop t ] "References" [ references inspect ] define-command

[ word? ] "See" [ see ] define-command
[ word? ] "Execute" [ execute ] define-command
[ word? ] "Usage" [ usage . ] define-command
[ word? ] "jEdit" [ jedit ] define-command

[ [ gadget? ] is? ] "Display" [ ] define-command
