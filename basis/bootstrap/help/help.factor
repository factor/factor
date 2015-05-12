USING: accessors assocs kernel namespaces sequences vocabs
vocabs.loader vocabs.loader.private ;
IN: bootstrap.help

: load-help ( -- )
    "help" require
    "help.topics" require
    "help.syntax" require
    "help.crossref" require
    "help.definitions" require
    "help.lint" require
    "help.vocabs" require

    t load-help? set-global

    [ dup lookup-vocab [ drop ] [ no-vocab ] if ] require-hook [
        dictionary get values
        [ docs-loaded?>> not ] filter
        [ load-docs ] each
    ] with-variable ;

load-help
