USING: help help.topics help.syntax help.crossref
help.definitions io io.files kernel namespaces vocabs sequences
parser vocabs.loader ;
IN: bootstrap.help

: load-help
    "alien.syntax" require
    "compiler" require

    t load-help? set-global

    [ drop ] load-vocab-hook [
        vocabs
        [ vocab-docs-loaded? not ] subset
        [ load-docs ] each
    ] with-variable ;

load-help
