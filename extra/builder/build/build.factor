
USING: io.files io.launcher io.encodings.utf8 prettyprint
       builder.util builder.common builder.child builder.release
       builder.report builder.email builder.cleanup ;

IN: builder.build

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: create-build-dir ( -- )
  datestamp >stamp
  build-dir make-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: enter-build-dir  ( -- ) build-dir set-current-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: clone-builds-factor ( -- )
  { "git" "clone" builds/factor } to-strings try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: record-id ( -- )
  "factor"
    [ git-id "../git-id" utf8 [ . ] with-file-writer ]
  with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: build ( -- )
  reset-status
  create-build-dir
  enter-build-dir
  clone-builds-factor
  record-id
  build-child
  release
  report
  email-report
  cleanup ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: build