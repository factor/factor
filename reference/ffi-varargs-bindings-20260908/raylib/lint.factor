USING: assocs help.lint help.lint.private kernel namespaces parser
raylib sequences system vocabs.loader ;
"raylib" reload
"resource:extra/raylib/raylib-docs.factor" run-file
{ trace-log text-format set-trace-log-callback } [ check-word ] each
"resource:basis/alien/syntax/syntax-docs.factor" run-file
"alien.syntax" help-lint
:lint-failures
lint-failures get assoc-empty? [ 0 ] [ 1 ] if exit
