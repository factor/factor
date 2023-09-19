USING: accessors continuations debugger environment eval globs
io io.directories io.encodings.utf8 io.launcher io.pathnames
io.pipes kernel namespaces sequences sequences.deep shell.parser
splitting words ;
IN: shell

: cd ( args -- )
    [ home ] [ first ] if-empty set-current-directory ;

: pwd ( args -- )
    drop current-directory get print ;

CONSTANT: swords { "cd" "pwd" }

GENERIC: expand ( expr -- expr )

M: object expand ;

M: single-quoted-expr expand expr>> ;

M: double-quoted-expr expand expr>> ;

M: variable-expr expand expr>> os-env ;

M: glob-expr expand expr>> glob ;

M: factor-expr expand expr>> eval>string ;

DEFER: expansion

M: back-quoted-expr expand
  expr>> expr command>> expansion process-contents
  " \n" split harvest ;

: expansion ( command -- command ) [ expand ] map flatten ;

: run-sword ( basic-expr -- )
    command>> expansion unclip
    "shell" lookup-word execute( arguments -- ) ;

: run-foreground ( process -- )
    [ try-process ] [ print-error drop ] recover ;

: run-background ( process -- )
    run-detached drop ;

: run-basic-expr ( basic-expr -- )
    <process>
        over command>> expansion >>command
        over stdin>>             >>stdin
        over stdout>>            >>stdout
        swap background>>
        [ run-background ] [ run-foreground ] if ;

: basic-chant ( basic-expr -- )
    dup command>> first swords member?
    [ run-sword ] [ run-basic-expr ] if ;

: pipeline-chant ( pipeline-chant -- )
    commands>> run-pipeline drop ;

: chant ( obj -- )
    dup basic-expr? [ basic-chant ] [ pipeline-chant ] if ;

: prompt ( -- )
    current-directory get write " $ " write flush ;

DEFER: shell

: handle ( input -- )
    dup { f "exit" } member? [
        drop
    ] [
        [
            expr [ chant ] [ "ix: ignoring input" print ] if*
        ] unless-empty shell
    ] if ;

: shell ( -- )
    prompt readln handle ;

: ix ( -- ) shell ;

MAIN: ix
