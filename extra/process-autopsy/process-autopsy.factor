! Copyright (C) 2018 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar combinators environment
escape-strings io io.pathnames io.streams.string kernel math
math.parser namespaces prettyprint prettyprint.config sequences
tools.deploy.backend tools.time unix.groups unix.users uuid ;
IN: process-autopsy

TUPLE: process-autopsy
    timestamp os-envs
    cwd uid euid gid egid out elapsed os-envs-after process ;

: ci-run-process ( process -- timestamp os-envs cwd uid euid gid egid out elapsed os-envs' process )
    [
        [
            now-gmt os-envs current-directory get
            real-user-id effective-user-id
            real-group-id effective-group-id
        ] dip [
            '[ _ run-with-output ] with-string-writer
        ] benchmark os-envs
    ] keep ;

: ci-run-process>autopsy ( process -- autopsy )
    ci-run-process process-autopsy boa ;

: unparse-full ( obj -- str )
    [ unparse ] without-limits ;

: autopsy. ( autopsy -- )
    {
        [ drop "<AUTOPSY: " uuid4 append print nl ]
        [
            bl bl timestamp>> timestamp>unix-time >float number>string
            "unix-time" tag-payload print nl
        ]
        [
            bl bl elapsed>> number>string "elapsed-nanos" tag-payload print nl
        ]
        [
            bl bl cwd>> "cwd" tag-payload print nl
        ]
        [
            bl bl uid>> number>string "uid" tag-payload print nl
        ]
        [
            bl bl euid>> number>string "euid" tag-payload print nl
        ]
        [
            bl bl gid>> number>string "gid" tag-payload print nl
        ]
        [
            bl bl egid>> number>string "egid" tag-payload print nl
        ]
        [
            bl bl os-envs>> unparse-full "os-envs" tag-payload print nl
        ]
        [
            bl bl os-envs>> unparse-full "os-envs-after" tag-payload print nl
        ]
        [
            bl bl [ os-envs-after>> ] [ os-envs>> ] bi assoc-diff unparse-full "os-envs-diff" tag-payload print nl
        ]
        [
            bl bl [ os-envs>> ] [ os-envs-after>> ] bi assoc-diff unparse-full "os-envs-swap-diff" tag-payload print nl
        ]
        [
            bl bl process>> unparse-full "process" tag-payload print nl
        ]
        [
            bl bl out>> "out" tag-payload print nl
        ]
        [ drop ";AUTOPSY>" print ]
    } cleave ;
