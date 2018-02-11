! Copyright (C) 2018 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.parser classes.tuple
combinators combinators.extras combinators.short-circuit
combinators.smart continuations fry io io.backend
io.encodings.utf8 io.files io.files.info io.launcher
io.pathnames io.standard-paths kernel lexer libc math math.order
multiline multiline.private namespaces parser prettyprint
sequences sequences.deep splitting strings system
system-info.macosx tools.hexdump unicode unix.signals unix.users
words ;
IN: factor-shell

! General utils.
: trim-blanks ( string -- string' ) [ blank? ] trim ; inline
: trim-head-blanks ( string -- string' ) [ blank? ] trim-head ; inline
: trim-tail-blanks ( string -- string' ) [ blank? ] trim-tail ; inline

GENERIC: find-command-path ( obj -- obj' )

M: sequence find-command-path
    0 over [ find-in-standard-login-path ] change-nth ;

M: process find-command-path
    [ find-command-path ] change-command ;

GENERIC#: run-process>string 1 ( command encoding -- string )

M: array run-process>string ( command encoding -- string )
    [ <process> swap >>command +new-session+ >>group ] dip

    [ find-command-path ] dip
    [ contents ] with-process-reader ; inline

M: string run-process>string
    [ <process> swap >>command  +new-session+ >>group ] dip

    [ contents ] with-process-reader ; inline

: run-utf8-process>string ( command -- string )
    utf8 run-process>string ; inline


! Shell things.
SYMBOL: factsh-directory-stack
factsh-directory-stack [ V{ } clone ] initialize

SYMBOL: previous-directory
SYMBOL: pending-directory


: pushd ( string -- )
    factsh-directory-stack get push ;

: popd ( -- string )
    factsh-directory-stack get pop ;
<<
: matching-delimiter ( ch -- ch' )
    H{
        { CHAR: ( CHAR: ) }
        { CHAR: [ CHAR: ] }
        { CHAR: { CHAR: } }
        { CHAR: < CHAR: > }
        { CHAR: : CHAR: ; }
    } ?at drop ;

: matching-delimiter-string ( string -- string' )
    [ matching-delimiter ] map ;    
>>

<<

SYNTAX: STRING-SYNTAX:
    scan-token
    [ create-class-in dup tuple { "payload" } define-tuple-class ]
    [ ] bi
    { "[[" "[=[" "[==[" "[===[" "[====[" } [
        [ append create-word-in dup reset-generic ]
        [ nip matching-delimiter-string ] 2bi
        rot
        '[ _ parse-multiline-string _ boa suffix! ] define-syntax
    ] with with each ;

>>

<<
! STRING-SYNTAX: FACTSH
STRING-SYNTAX: FACTOR
STRING-SYNTAX: PYTHON
STRING-SYNTAX: RUBY
>>

GENERIC: execute-string ( obj -- string )
M: FACTOR execute-string
    payload>> "-e=" prepend vm-path swap 2array run-utf8-process>string ;
M: PYTHON execute-string
    payload>> 1array { "python" "-c" } prepend run-utf8-process>string ;
M: RUBY execute-string
    payload>> 1array { "ruby" "-e" } prepend run-utf8-process>string ;

ERROR: expected-len1 obj ;
: len1 ( seq -- obj ) dup length 1 = [ first ] [ expected-len1 ] if ;
ERROR: expected-len2 obj ;
: len2 ( seq -- obj1 obj2 ) dup length 2 = [ first2 ] [ expected-len2 ] if ;

: find-binary-name ( string -- string/path ? )
    dup find-in-standard-login-path [ nip t ] [ f ] if* ;

: transfer ( var1 var2 -- )
    [ get ] dip set ; inline

: swap-vars ( var1 var2 -- )
    [ [ get ] bi@ ] 2keep [ set ] dip set ; inline

ERROR: builtin-failed command argument message ;
: check-directory-exists ( to -- to )
    dup { [ exists? ] [ file-info directory? ] } 1&&
    [ "cd" swap "No such directory" builtin-failed ] unless ;

: root-path ( path -- path' )
    dup absolute-path? [
        dup [ path-separator? ] find
        drop 1 + head
    ] when ;

: relative-path ( path -- relative-path )
    dup absolute-path? [
        dup [ path-separator? ] find
        drop 1 + tail
    ] when ;

: canonicalize-path ( path -- path' )
    [
        relative-path
        [ path-separator? ] split-when
        [ { "." "" } member? ] reject
        V{ } clone [
            dup ".." = [
                over empty?
                [ over push ]
                [ over ?last ".." = [ over push ] [ drop dup pop* ] if ] if
            ] [
                over push
            ] if
        ] reduce
    ] keep dup absolute-path? [
        [
            [ ".." = ] trim-head
            path-separator join
        ] dip root-path prepend-path 
    ] [
        drop path-separator join [ "." ] when-empty
    ] if ;

: count-canonical-path-components ( path -- n )
    canonicalize-path [ CHAR: / = ] count 1 + ;

: mismatch-tail ( seq1 seq2 -- seq1 seq2 )
    2dup mismatch [ 2dup [ length ] bi@ min ] unless*
    '[ _ tail ] bi@ ;

! c:\ vs d:\ -- no relative path possible. also impossible on unix.
: derive-both-absolute ( absolute-path1 absolute-path2 -- path1-relative-to-path2 )
    [ "/" split ] bi@ mismatch-tail [ "/" join ] bi@
    count-canonical-path-components
    [ ".." ] replicate "/" join prepend-path ;

: derive-relative-path ( path1 path2 -- path1-relative-to-path2 )
    [ canonicalize-path ] bi@
    {
        { [ 2dup [ absolute-path ] both? ] [ derive-both-absolute ] }
        [ "unimplemented" throw ]
    } cond ; inline

: home-directory? ( path -- ? ) "~" head? ;
: current-directory? ( path -- ? ) "./" head? ;

: fixup-home-directory ( path -- path' )
    [ path-separator? ] split-when
    dup first length 1 > [
        unclip [ "/" join ] [ rest home parent-directory prepend ] bi* append
    ] [
        "/" join
    ] if ;

: our-cd ( args -- string/f )
    '[
        _ [ trim-blanks ] map
        current-directory pending-directory transfer
        [
            current-directory '[ drop home ] change
        ] [
            {
                { [ dup { "-" } sequence= ] [ drop previous-directory get current-directory set ] }
                { [ dup first home-directory? ] [ first fixup-home-directory current-directory set ] }
                ! { { "-L" } [ ] }
                ! { { "-P" } [ ] }
                [ len1 normalize-path canonicalize-path check-directory-exists current-directory set ]
            } cond
        ] if-empty
        pending-directory previous-directory transfer f
    ] [
        unparse
    ] recover ;

SYMBOL: exit-shell?

ERROR: unknown-command cmd args ;
: eval-factsh ( string -- string-output )
    [ blank? ] trim-head " " split harvest [
        f
    ] [
        unclip {
            { "cd" [ our-cd ] }
            { "ls" [ { "ls" } prepend utf8 run-process>string ] }
            { "pwd" [ drop current-directory get "\n" append ] }
            { "exit" [ [ 0 exit-shell? set ] [ len1 exit-shell? set ] if-empty "logout\n" ] }
            ! { "pushd" [ len1 current-directory get ] }
            ! { "popd" [ current-directory get ] }
            [
                dup current-directory? [
                    dup current-directory get prepend-path
                    dup exists? [
                        2nip run-utf8-process>string
                    ] [
                        swap unknown-command
                    ] if
                ] [
                    find-binary-name [ prefix run-utf8-process>string ]
                    [ swap unknown-command ] if
                ] if
            ]
        } case
    ] if-empty ;

: computer-name ( -- string ) { 1 10 } sysctl-query-string "." split1 drop ;

: osx-bash-prompt ( -- string )
    [
        computer-name ":"
        current-directory get
        dup home = [ drop "~" ] [ file-name ] if
        " " real-user-name "$ >> "
    ] "" append-outputs-as ;

: echo-prompt ( -- )
    osx-bash-prompt write flush ;

SYMBOL: shell-last-exit

GENERIC: handle-repl-error ( obj -- )
M: unknown-command handle-repl-error
    cmd>> ": command not found" append print ;

M: process-failed handle-repl-error
    process>> status>> shell-last-exit set ;

: factsh-repl ( -- )
    ! [ "hello SIGUSR1" print flush ] SIGUSR1 add-signal-handler
    [ "hello SIGINT" print flush ] SIGINT add-signal-handler
    [ "hello SIGSTOP" print flush ] SIGSTOP add-signal-handler
    [ "hello SIGQUIT" print flush ] SIGQUIT add-signal-handler
    [ "hello SIGHUP" print flush ] SIGHUP add-signal-handler
    [ "hello SIGTERM" print flush ] SIGTERM add-signal-handler
    [ "hello SIGHUP" print flush ] SIGHUP add-signal-handler

    f exit-shell? [
        current-directory previous-directory transfer
        [
            [ echo-prompt readln [ eval-factsh [ write ] when* ] [ nl t exit-shell? set ] if* ]
            [ handle-repl-error ] recover
            exit-shell? get not
        ] loop
    ] with-variable ;

MAIN: factsh-repl
! PYTHON[[ print("hi")]] execute-string
! RUBY[[ printf('hello')]] execute-string
! FACTOR[[ USE: io "hi" print ]]  execute-string


! stty -a
! ps ax -O tpgid
! http://unix.stackexchange.com/questions/149741/why-is-sigint-not-propagated-to-child-process-when-sent-to-its-parent-process

