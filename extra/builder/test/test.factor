
USING: kernel namespaces sequences assocs builder continuations
       vocabs vocabs.loader
       io
       io.files
       prettyprint
       tools.browser
       tools.test
       bootstrap.stage2 ;

IN: builder.test

: do-load ( -- )
  try-everything keys "../load-everything-vocabs" [ . ] with-file-out ;

: do-tests ( -- )
  run-all-tests keys "../test-all-vocabs" [ . ] with-file-out ;

: do-all ( -- )
  bootstrap-time get   "../boot-time" [ . ] with-file-out
  [ do-load  ] runtime "../load-time" [ . ] with-file-out
  [ do-tests ] runtime "../test-time" [ . ] with-file-out ;

MAIN: do-all