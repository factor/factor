IN: gadgets-presentations
USING: compiler gadgets gadgets-buttons gadgets-menus
gadgets-panes generic hashtables inference inspector jedit
kernel lists namespaces parser prettyprint sequences words ;

SYMBOL: commands

V{ } clone commands global set-hash

: forget-command ( name -- )
    commands [ [ second = not ] subset-with ] change ;

: define-command ( class name quot -- )
    over forget-command 3array commands get push ;

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
