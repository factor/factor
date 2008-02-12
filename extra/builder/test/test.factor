
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

! : try-everything* ( -- vocabs ) try-everything [ first vocab-link-name ] map ;

! : do-load ( -- )
!   [
!     "../load-everything-log" <file-writer>
!       [ try-everything keys ]
!     with-stream
!   ] "../load-everything-time" log-runtime
!   dup empty?
!     [ drop ]
!     [ "../load-everything-vocabs" log-object ]
!   if
!   "../load-everything-log" delete-file ;

: do-load ( -- )
  [ try-everything keys ] "../load-everything-time" log-runtime
  dup empty?
    [ drop ]
    [ "../load-everything-vocabs" log-object ]
  if ;

! : do-tests ( -- )
!   run-all-tests keys
!   dup empty?
!   [ drop ]
!   [ "../failing-tests" log-object ]
!   if ;

! : do-tests ( -- )
!   [
!     "../test-all-log" <file-writer>
!       [ run-all-tests keys ]
!     with-stream
!   ] "../test-all-time" log-runtime
!   dup empty?
!     [ drop ]
!     [ "../test-all-vocabs" log-object ]
!   if
!   "../test-all-log" delete-file ;

: do-tests ( -- )
  [ run-all-tests keys ] "../test-all-time" log-runtime
  dup empty?
    [ drop ]
    [ "../test-all-vocabs" log-object ]
  if ;

! : do-all ( -- )
!   record-bootstrap-time
!   [ do-load ]  [ drop ] recover
!   [ do-tests ] [ drop ] recover ;

: do-all ( -- )
  record-bootstrap-time
  do-load
  do-tests ;

MAIN: do-all