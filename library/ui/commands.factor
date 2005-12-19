IN: gadgets-presentations
USING: compiler gadgets gadgets-buttons gadgets-menus
gadgets-panes generic hashtables inference inspector io jedit
kernel lists namespaces parser prettyprint sequences words ;

SYMBOL: commands

TUPLE: command name pred quot default? ;

V{ } clone commands global set-hash

: forget-command ( name -- )
    global [
        commands [ [ command-name = not ] subset-with ] change
    ] bind ;

: (define-command) ( name pred quot default? -- )
    <command> dup command-name forget-command commands get push ;

: define-command ( name pred quot -- )
    f (define-command) ;

: define-default-command ( name pred quot -- )
    t (define-command) ;

: applicable ( object -- seq )
    commands get [ command-pred call ] subset-with ;

: command>quot ( presented command -- quot )
    command-quot curry [ pane get pane-call ] curry ;

TUPLE: command-button object ;

: command-action ( command-button -- )
    #! Invoke the default action.
    command-button-object dup applicable
    [ command-default? ] find-last nip command>quot call ;

: <command-menu-item> ( presented command -- item )
    [ command>quot [ drop ] swap append ] keep
    command-name swons ;

: <command-menu> ( presented -- menu )
    dup applicable
    [ <command-menu-item> ] map-with <menu> ;

: command-menu ( command-button -- )
    dup button-update
    command-button-object <command-menu>
    show-hand-menu ;

: command-button-actions ( gadget -- )
    dup
    [ command-menu ] [ button-down 3 ] set-action
    [ button-update ] [ button-up 3 ] set-action ;

C: command-button ( gadget object -- button )
    [ set-command-button-object ] keep
    [
        >r [ command-action ] <roll-button> r>
        set-gadget-delegate
    ] keep
    dup command-button-actions ;

M: command-button gadget-help ( button -- string )
    command-button-object dup word? [ synopsis ] [ summary ] if ;

"Describe" [ drop t ] [ describe ] define-default-command
"Prettyprint" [ drop t ] [ . ] define-command
"Push on data stack" [ drop t ] [ ] define-command

"See word" [ word? ] [ see ] define-default-command
"Word call hierarchy" [ word? ] [ uses. ] define-command
"Word caller hierarchy" [ word? ] [ usage. ] define-command
"Open in jEdit" [ word? ] [ jedit ] define-command
"Reload original source" [ word? ] [ reload ] define-command
"Annotate with watchpoint" [ compound? ] [ watch ] define-command
"Annotate with breakpoint" [ compound? ] [ break ] define-command
"Annotate with profiling" [ compound? ] [ profile ] define-command
"Compile" [ word? ] [ recompile ] define-command
"Infer stack effect" [ word? ] [ unit infer . ] define-command

"Display gadget" [ [ gadget? ] is? ] [ gadget. ] define-command

"Use as input" [ input? ] [ input-string pane get replace-input ] define-default-command
