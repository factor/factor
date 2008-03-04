
USING: kernel namespaces sequences assocs builder continuations
       vocabs vocabs.loader
       io
       io.files
       prettyprint
       tools.browser
       tools.test
       bootstrap.stage2 benchmark builder.util ;

IN: builder.test

: do-load ( -- )
  try-everything keys "../load-everything-vocabs" [ . ] with-file-writer ;

: do-tests ( -- )
  run-all-tests keys "../test-all-vocabs" [ . ] with-file-writer ;

: do-benchmarks ( -- ) run-benchmarks "../benchmarks" [ . ] with-file-writer ;

: do-all ( -- )
  bootstrap-time get   "../boot-time" [ . ] with-file-writer
  [ do-load  ] runtime "../load-time" [ . ] with-file-writer
  [ do-tests ] runtime "../test-time" [ . ] with-file-writer
  do-benchmarks ;

MAIN: do-all