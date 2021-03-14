
USING: accessors ascii assocs combinators grouping io kernel
math sequences sorting splitting ;

IN: command-loop

TUPLE: command name quot help abbrevs ;

C: <command> command

TUPLE: command-loop intro prompt commands abbrevs ;

GENERIC: add-command ( command command-loop -- )
GENERIC: find-command ( name command-loop -- command )
GENERIC: handle-command ( args command-loop -- )
GENERIC: missing-command ( args name command-loop -- )
GENERIC: run-command-loop ( command-loop -- )

<PRIVATE

: do-help ( args command-loop -- )
    over empty? [
        "Available commands:" print
        "-------------------" print
        nip commands>> [ name>> ] map natural-sort
        [ 6 <groups> ] [ longest length 4 + ] bi
        '[ [ _ CHAR: \s pad-tail write ] each nl ] each
    ] [
        dupd find-command [
            nip help>> print
        ] [
            "ERROR: Command '" "' not found" surround print
        ] if*
    ] if ;

: <help-command> ( command-loop -- command )
    "help" swap '[ _ do-help ]
    "List available commands with 'help' or detailed help with 'help cmd'"
    { "?" } <command> ;

PRIVATE>

: new-command-loop ( intro prompt class -- command-loop )
    new
        swap >>prompt
        swap >>intro
        V{ } clone >>commands
        V{ } clone >>abbrevs
    [ <help-command> ] [ add-command ] [ ] tri ;

: <command-loop> ( intro prompt -- command-loop )
    command-loop new-command-loop ;

M: command-loop add-command ( command command-loop -- )
    {
        [ commands>> push ]
        [ [ [ name>> ] keep ] dip [ abbrevs>> ] bi@ '[ _ set-at ] with each ]
    } 2cleave ;

M: command-loop find-command ( name command-loop -- command )
    [ abbrevs>> ?at drop ]
    [ commands>> [ name>> = ] with find nip ] bi ;

M: command-loop handle-command
    swap " " split1 swap >lower
    [ pick find-command ] keep swap [
        nip quot>> call( args -- ) drop
    ] [
        rot missing-command
    ] if* flush ;

M: command-loop missing-command ( args name command-loop -- )
    drop "ERROR: Unknown command '" "'" surround print drop ;

M: command-loop run-command-loop
    dup intro>> [ print ] when* [
        dup prompt>> [ write bl flush ] when* readln
        [ [ over handle-command ] unless-empty t ] [ f ] if*
    ] loop drop ;

: command-loop-main ( -- )
    "This is a test!" "TEST>" <command-loop> run-command-loop ;

MAIN: command-loop-main
