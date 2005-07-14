! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: gadgets
USING: generic hashtables inspector io jedit kernel lists memory
namespaces parser prettyprint sequences styles vectors words ;

SYMBOL: commands

global [ 100 <vector> commands set ] bind

: define-command ( class name quot -- )
    3list commands get push ;

: applicable ( object -- list )
    commands get >list [ car call ] subset-with ;

: command-quot ( presented quot -- quot )
    [ swap literal, % ] make-list
    [ pane get pane-call drop ] cons ;

: command-menu ( presented -- menu )
    dup applicable
    [ [ third command-quot ] keep second swons ] map-with
    <menu> ;

: init-commands ( gadget -- )
    dup presented paint-prop dup [
        [
            \ drop ,
            literal,
            [ command-menu show-menu ] %
        ] make-list
        button-gestures
    ] [
        2drop
    ] ifte ;

: <styled-label> ( style text -- label )
    <label> swap dup [ alist>hash ] when over set-gadget-paint ;

: <presentation> ( style text -- presentation )
    gadget pick assoc dup
    [ 2nip ] [ drop <styled-label> dup init-commands ] ifte ;

: gadget. ( gadget -- )
    gadget swons unit "" swap write-attr terpri ;

[ drop t ] "Prettyprint" [ prettyprint ] define-command
[ drop t ] "Inspect" [ inspect ] define-command
[ drop t ] "References" [ references inspect ] define-command

[ word? ] "See" [ see ] define-command
[ word? ] "Execute" [ execute ] define-command
[ word? ] "Usage" [ usage . ] define-command
[ word? ] "jEdit" [ jedit ] define-command

[ [ gadget? ] is? ] "Display" [ gadget. ] define-command
