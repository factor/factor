
USING: kernel namespaces assocs
       io.files io.encodings.utf8 prettyprint 
       help.lint
       benchmark
       tools.time
       bootstrap.stage2
       tools.test tools.vocabs
       builder.util ;

IN: builder.test

: do-load ( -- )
  try-everything keys "../load-everything-vocabs" utf8 [ . ] with-file-writer ;

: do-tests ( -- )
  run-all-tests
    [ keys "../test-all-vocabs" utf8 [ .              ] with-file-writer ]
    [      "../test-failures"   utf8 [ test-failures. ] with-file-writer ]
  bi ;

: do-help-lint ( -- )
  "" run-help-lint "../help-lint" utf8 [ typos. ] with-file-writer ;

: do-benchmarks ( -- )
  run-benchmarks "../benchmarks" utf8 [ . ] with-file-writer ;

: do-all ( -- )
  bootstrap-time get   "../boot-time" utf8 [ . ] with-file-writer
  [ do-load  ] benchmark "../load-time" utf8 [ . ] with-file-writer
  [ do-tests ] benchmark "../test-time" utf8 [ . ] with-file-writer
  do-help-lint
  do-benchmarks ;

MAIN: do-all