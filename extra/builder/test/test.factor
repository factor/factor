
USING: kernel sequences assocs builder continuations vocabs vocabs.loader
       io
       io.files
       tools.browser
       tools.test ;

IN: builder.test

: try-everything* ( -- vocabs ) try-everything [ first vocab-link-name ] map ;

: do-load ( -- )
  [ try-everything* ] "../load-everything-time" log-runtime
  dup empty?
    [ drop ]
    [ "../load-everything-log" log-object ]
  if ;

: do-tests ( -- )
  run-all-tests keys
  dup empty?
  [ drop ]
  [ "../failing-tests" log-object ]
  if ;

: do-all ( -- ) do-load do-tests ;

MAIN: do-all