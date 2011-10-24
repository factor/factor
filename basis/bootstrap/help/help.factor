USING: help help.topics help.syntax help.crossref
help.definitions io io.files kernel namespaces vocabs sequences
parser vocabs.loader vocabs.loader.private accessors assocs ;
IN: bootstrap.help

: load-help ( -- )
    "help.lint" require
    "help.vocabs" require

    t load-help? set-global

    [ dup lookup-vocab [ ] [ no-vocab ] ?if ] load-vocab-hook [
        dictionary get values
        [ docs-loaded?>> not ] filter
        [ load-docs ] each
    ] with-variable ;

load-help
