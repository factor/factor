USING: help help.topics help.syntax help.crossref
help.definitions io io.files kernel namespaces sequences
parser vocabs vocabs.loader vocabs.loader.private accessors assocs ;
IN: bootstrap.help

: load-help ( -- )
    "help.lint" require
    "help.vocabs" require

    t load-help? set-global

    [ dup lookup-vocab [ ] [ no-vocab ] ?if ] require-hook [
        dictionary get values
        [ docs-loaded?>> not ] filter
        [ load-docs ] each
    ] with-variable ;

load-help
