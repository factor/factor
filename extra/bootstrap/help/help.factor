USING: help help.topics help.syntax help.crossref
help.definitions io io.files kernel namespaces vocabs sequences
parser vocabs.loader ;
IN: bootstrap.help

: load-help
    t load-help? set-global

    [ vocab ] load-vocab-hook [
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
    ] with-variable

    "help.handbook" require ;

load-help
