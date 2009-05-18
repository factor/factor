! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces sequences splitting system accessors
math.functions make io io.files io.pathnames io.directories
io.directories.hierarchy io.launcher io.encodings.utf8 prettyprint
combinators.short-circuit parser combinators calendar
calendar.format arrays mason.config locals system debugger fry
continuations strings ;
IN: mason.common

SYMBOL: current-git-id

: short-running-process ( command -- )
    #! Give network operations and shell commands at most
    #! 15 minutes to complete, to catch hangs.
    >process
        15 minutes >>timeout
        +closed+ >>stdin
    try-output-process ;

HOOK: really-delete-tree os ( path -- )

M: windows really-delete-tree
    #! Workaround: Cygwin GIT creates read-only files for
    #! some reason.
    [ { "chmod" "ug+rw" "-R" } swap (normalize-path) suffix short-running-process ]
    [ delete-tree ]
    bi ;

M: unix really-delete-tree delete-tree ;

: retry ( n quot -- )
    '[ drop @ f ] attempt-all drop ; inline

:: upload-safely ( local username host remote -- )
    [let* | temp [ remote ".incomplete" append ]
            scp-remote [ { username "@" host ":" temp } concat ]
            scp [ scp-command get ]
            ssh [ ssh-command get ] |
        5 [ { scp local scp-remote } short-running-process ] retry
        5 [ { ssh host "-l" username "mv" temp remote } short-running-process ] retry
    ] ;

: eval-file ( file -- obj )
    dup utf8 file-lines parse-fresh
    [ "Empty file: " swap append throw ] [ nip first ] if-empty ;

: cat ( file -- ) utf8 file-contents print ;

: cat-n ( file n -- ) [ utf8 file-lines ] dip short tail* [ print ] each ;

: to-file ( object file -- ) utf8 [ . ] with-file-writer ;

: datestamp ( timestamp -- string )
    [
        {
            [ year>> , ]
            [ month>> , ]
            [ day>> , ]
            [ hour>> , ]
            [ minute>> , ]
        } cleave
    ] { } make [ pad-00 ] map "-" join ;

: milli-seconds>time ( n -- string )
    millis>timestamp
    [ hour>> ] [ minute>> ] [ second>> floor ] tri 3array
    [ pad-00 ] map ":" join ;

SYMBOL: stamp

: builds/factor ( -- path ) builds-dir get "factor" append-path ;
: build-dir ( -- path ) builds-dir get stamp get append-path ;

: prepare-build-machine ( -- )
    builds-dir get make-directories
    builds-dir get
    [ { "git" "clone" "git://factorcode.org/git/factor.git" } try-output-process ]
    with-directory ;

: git-id ( -- id )
    { "git" "show" } utf8 [ lines ] with-process-reader
    first " " split second ;

: ?prepare-build-machine ( -- )
    builds/factor exists? [ prepare-build-machine ] unless ;

CONSTANT: load-all-vocabs-file "load-everything-vocabs"
CONSTANT: load-all-errors-file "load-everything-errors"

CONSTANT: test-all-vocabs-file "test-all-vocabs"
CONSTANT: test-all-errors-file "test-all-errors"

CONSTANT: help-lint-vocabs-file "help-lint-vocabs"
CONSTANT: help-lint-errors-file "help-lint-errors"

CONSTANT: compiler-errors-file "compiler-errors"
CONSTANT: compiler-error-messages-file "compiler-error-messages"

CONSTANT: boot-time-file "boot-time"
CONSTANT: load-time-file "load-time"
CONSTANT: test-time-file "test-time"
CONSTANT: help-lint-time-file "help-lint-time"
CONSTANT: benchmark-time-file "benchmark-time"
CONSTANT: html-help-time-file "html-help-time"

CONSTANT: benchmarks-file "benchmarks"
CONSTANT: benchmark-error-messages-file "benchmark-error-messages"
CONSTANT: benchmark-error-vocabs-file "benchmark-error-vocabs"

SYMBOL: status-error ! didn't bootstrap, or crashed
SYMBOL: status-dirty ! bootstrapped but not all tests passed
SYMBOL: status-clean ! everything good
