USING: assocs compiler.errors debugger io kernel namespaces parser
sequences vocabs.refresh ;
"Refreshing original root image with rebuilt VM" print flush
refresh-all
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? [ "Refresh left compiler errors" throw ] unless
"Refresh completed without compiler errors" print flush
"resource:reference/lazy-arm64-callback-template-20260908/callback-tests.factor" run-file
