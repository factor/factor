
USING: kernel sequences assocs builder continuations vocabs vocabs.loader
       io
       io.files
       tools.browser
       tools.test ;

IN: builder.test

! : do-load ( -- )
!   [
!     [ load-everything ]
!     [ require-all-error-vocabs "../load-everything-log" log-object ]
!     recover
!   ]
!   "../load-everything-time" log-runtime ;

: do-load ( -- )
  [ try-everything ] "../load-everything-time" log-runtime
  dup empty?
    [ drop ]
    [ "../load-everything-log" log-object ]
  if ;

! : do-tests ( -- )
!   "" child-vocabs
!   [ vocab-source-loaded? ] subset
!   [ vocab-tests-path ] map
!   [ dup [ ?resource-path exists? ] when ] subset
!   [ dup run-test ] { } map>assoc
!   [ second empty? not ] subset
!   dup empty?
!   [ drop ]
!   [
!     "../failing-tests" <file-writer>
!       [ [ nl failures. ] assoc-each ]
!     with-stream
!   ]
!   if ;

: do-tests ( -- )
  run-all-tests keys
  dup empty?
  [ drop ]
  [ "../failing-tests" log-object ]
  if ;

: do-all ( -- ) do-load do-tests ;

MAIN: do-all