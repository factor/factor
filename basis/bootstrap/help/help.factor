USING: accessors assocs namespaces sequences vocabs vocabs.loader
vocabs.loader.private ;
IN: bootstrap.help

: load-help ( -- )
    {
        "help"
        "help.topics"
        "help.syntax"
        "help.crossref"
        "help.definitions"
        "help.lint"
        "help.vocabs"
    } [ require ] each

    t load-help? set-global

    dictionary get values [ docs-loaded?>> ] reject [ load-docs ] each ;

load-help
