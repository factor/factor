! Copyright (C) 2021 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors ascii assocs combinators continuations debugger
formatting grouping io io.encodings.utf8 io.files kernel math
sequences sorting splitting ;

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
        nl
        "Commands available:" print
        "===================" print
        nip commands>> [ name>> ] map sort
        [ 6 <groups> ] [ longest length 4 + ] bi
        '[ [ _ CHAR: \s pad-tail write ] each nl ] each nl
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

: do-abbrevs ( args command-loop -- )
    nl
    "Commands abbreviated:" print
    "=====================" print
    nip abbrevs>> sort-keys [
        "%-7s %s\n" printf
    ] assoc-each nl ;

: <abbrevs-command> ( command-loop -- command )
    "abbrevs" swap '[ _ do-abbrevs ]
    "List abbreviated commands" f <command> ;

: ?handle-command ( args command-loop -- )
    '[
        [ _ handle-command ]
        [ "ERROR: " write print-error drop ] recover
    ] unless-empty ;

: do-run ( args command-loop -- )
    [ utf8 file-lines ] dip '[ _ handle-command ] each ;

: <run-command> ( command-loop -- command )
    "run" swap '[ _ do-run ]
    "Execute commands in a specified file with 'run /path/to/commands'."
    f <command> ;

PRIVATE>

: new-command-loop ( intro prompt class -- command-loop )
    new
        swap >>prompt
        swap >>intro
        V{ } clone >>commands
        V{ } clone >>abbrevs {
        [ <help-command> ]
        [ add-command ]
        [ <abbrevs-command> ]
        [ add-command ]
        [ <run-command> ]
        [ add-command ]
        [ ]
    } cleave ;

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
    [ pick find-command ] 1check [
        nip quot>> call( args -- ) drop
    ] [
        rot missing-command
    ] if* flush ;

M: command-loop missing-command ( args name command-loop -- )
    drop "ERROR: Unknown command '" "'" surround print drop ;

M: command-loop run-command-loop
    dup intro>> [ print ] when* [
        dup prompt>> [ write bl flush ] when* readln
        [ over ?handle-command t ] [ f ] if*
    ] loop drop ;

: command-loop-main ( -- )
    "This is a test!" "TEST>" <command-loop> run-command-loop ;

MAIN: command-loop-main
