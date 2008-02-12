
USING: kernel sequences assocs builder continuations vocabs vocabs.loader
       io
       io.files
       tools.browser
       tools.test ;

IN: builder.test

: record-bootstrap-time ( -- )
  "../bootstrap-time" <file-writer>
    [ bootstrap-time get . ]
  with-stream ;

: try-everything* ( -- vocabs ) try-everything [ first vocab-link-name ] map ;

! : do-load ( -- )
!   [ try-everything* ] "../load-everything-time" log-runtime
!   dup empty?
!     [ drop ]
!     [ "../load-everything-log" log-object ]
!   if ;

: do-load ( -- )
  [
    "../load-everything-log" <file-writer>
      [ try-everything* ]
    with-stream
  ] "../load-everything-time" log-runtime
  dup empty?
    [ drop ]
    [ "../load-everything-vocabs" log-object ]
  if
  "../load-everything-log" delete-file ;

! : do-tests ( -- )
!   run-all-tests keys
!   dup empty?
!   [ drop ]
!   [ "../failing-tests" log-object ]
!   if ;

: do-tests ( -- )
  [
    "../test-all-log" <file-writer>
      [ run-all-tests keys ]
    with-stream
  ] "../test-all-time" log-runtime
  dup empty?
    [ drop ]
    [ "../test-all-vocabs" log-object ]
  if
  "../test-all-log" delete-file ;

: do-all ( -- )
  record-bootstrap-time
  do-load
  do-tests ;

MAIN: do-all