
USING: kernel namespaces sequences assocs builder continuations
       vocabs vocabs.loader
       io
       io.files
       prettyprint
       tools.vocabs
       tools.test
       io.encodings.utf8
       combinators.cleave
       help.lint
       bootstrap.stage2 benchmark builder.util ;

IN: builder.test

: do-load ( -- )
  try-everything keys "../load-everything-vocabs" utf8 [ . ] with-file-writer ;

! : do-tests ( -- )
!   run-all-tests keys "../test-all-vocabs" utf8 [ . ] with-file-writer ;

: do-tests ( -- )
  run-all-tests
    [ keys "../test-all-vocabs" utf8 [ .              ] with-file-writer ]
    [      "../test-failures"   utf8 [ test-failures. ] with-file-writer ]
  bi ;

! : do-tests ( -- )
!   run-all-tests
!   "../test-all-vocabs" utf8
!     [
!         [ keys . ]
!         [ test-failures. ]
!       bi
!     ]
!   with-file-writer ;

: do-help-lint ( -- )
  "" run-help-lint "../help-lint" utf8 [ typos. ] with-file-writer ;

: do-benchmarks ( -- )
  run-benchmarks "../benchmarks" utf8 [ . ] with-file-writer ;

: do-all ( -- )
  bootstrap-time get   "../boot-time" utf8 [ . ] with-file-writer
  [ do-load  ] runtime "../load-time" utf8 [ . ] with-file-writer
  [ do-tests ] runtime "../test-time" utf8 [ . ] with-file-writer
  do-help-lint
  do-benchmarks ;

MAIN: do-all