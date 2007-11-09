USING: help help.topics help.syntax help.crossref
help.definitions io io.files kernel namespaces vocabs sequences
parser vocabs.loader ;
IN: bootstrap.help

: load-help
    t load-help? set-global

    vocabs
    [ vocab-root ] subset
    [ vocab-source-loaded? ] subset
    [
        dup vocab-docs-loaded? [
            drop
        ] [
            dup vocab-root swap load-docs
        ] if
    ] each

    "help.handbook" require

    global [ "help" use+ ] bind ;

load-help
