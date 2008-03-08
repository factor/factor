
USING: kernel namespaces sequences assocs builder continuations
       vocabs vocabs.loader
       io
       io.files
       prettyprint
       tools.browser
       tools.test
       io.encodings.utf8
       bootstrap.stage2 benchmark builder.util ;

IN: builder.test

: do-load ( -- )
  try-everything keys "../load-everything-vocabs" utf8 [ . ] with-file-writer ;

: do-tests ( -- )
  run-all-tests keys "../test-all-vocabs" utf8 [ . ] with-file-writer ;

: do-benchmarks ( -- )
  run-benchmarks "../benchmarks" utf8 [ . ] with-file-writer ;

: do-all ( -- )
  bootstrap-time get   "../boot-time" utf8 [ . ] with-file-writer
  [ do-load  ] runtime "../load-time" utf8 [ . ] with-file-writer
  [ do-tests ] runtime "../test-time" utf8 [ . ] with-file-writer
  do-benchmarks ;

MAIN: do-all