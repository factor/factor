
USING: kernel namespaces sequences assocs builder continuations
       vocabs vocabs.loader
       io
       io.files
       prettyprint
       tools.browser
       tools.test
       bootstrap.stage2 ;

IN: builder.test

: record-bootstrap-time ( -- )
  "../bootstrap-time" <file-writer>
    [ bootstrap-time get . ]
  with-stream ;

: do-load ( -- )
  [ try-everything keys ] "../load-everything-time" log-runtime
  dup empty?
    [ drop ]
    [ "../load-everything-vocabs" log-object ]
  if ;

: do-tests ( -- )
  [ run-all-tests keys ] "../test-all-time" log-runtime
  dup empty?
    [ drop ]
    [ "../test-all-vocabs" log-object ]
  if ;

: do-all ( -- )
  record-bootstrap-time
  do-load
  do-tests ;

MAIN: do-all