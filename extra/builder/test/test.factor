
USING: kernel sequences assocs builder continuations vocabs vocabs.loader
       io
       io.files
       tools.browser
       tools.test ;

IN: builder.test

: do-load ( -- )
  [ [ load-everything ] catch ] "../load-everything-time" log-runtime
  [ require-all-error-vocabs    "../load-everything-log"  log-object ]
  when* ;

: do-tests ( -- )
  "" child-vocabs
  [ vocab-source-loaded? ] subset
  [ vocab-tests-path ] map
  [ dup [ ?resource-path exists? ] when ] subset
  [ dup run-test ] { } map>assoc
  [ second empty? not ] subset
  dup empty?
  [ drop ]
  [
    "../failing-tests" <file-writer>
      [ [ nl failures. ] assoc-each ]
    with-stream
  ]
  if ;

: do-all ( -- ) do-load do-tests ;

MAIN: do-all