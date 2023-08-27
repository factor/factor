! Copyright (C) 2019 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: assocs command-line help.lint io kernel namespaces
prettyprint sequences system vocabs ;
IN: zealot.help-lint

! FIXME: help-lint sometimes lists monitors and event-streams as leaked.
! event-stream is macosx-only so hack it into a string
CONSTANT: ignored-resources {
    "linux-monitor" "macosx-monitor" "malloc-ptr"
    "epoll-mx" "server-port" "openssl-context"
    "cache-assoc" "input-port" "fd" "output-port" "stdin"
    "event-stream"
}

: filter-flaky-resources ( seq -- seq' )
    [ drop unparse ignored-resources member? ] assoc-reject ;

! Allow testing without calling exit
: zealot-help-lint ( exit? -- )
    command-line get require-all
    help-lint-all
    lint-failures get filter-flaky-resources
    [ nip assoc-empty? [ "==== FAILING LINT" print :lint-failures flush ] unless ]
    [ swap [ 0 1 ? (exit) ] [ drop ] if ] 2bi ;

: zealot-help-lint-main ( -- )
    t zealot-help-lint ;

MAIN: zealot-help-lint-main
