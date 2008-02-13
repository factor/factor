
USING: kernel parser io io.files io.launcher io.sockets hashtables math threads
       arrays system continuations namespaces sequences splitting math.parser
       prettyprint tools.time calendar bake vars http.client
       combinators bootstrap.image bootstrap.image.download
       combinators.cleave benchmark ;

IN: builder

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: runtime ( quot -- time ) benchmark nip ;

: minutes>ms ( min -- ms ) 60 * 1000 * ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: builder-recipients

: host-name* ( -- name ) host-name "." split first ;

: tag-subject ( str -- str ) `{ "builder@" ,[ host-name* ] ": " , } concat ;

: email-string ( subject -- )
  `{ "mutt" "-s" ,[ tag-subject ] %[ builder-recipients get ] }
  [ ] with-process-stream drop ;

: email-file ( subject file -- )
  `{
    { +stdin+ , }
    { +arguments+
      { "mutt" "-s" ,[ tag-subject ] %[ builder-recipients get ] } }
  }
  >hashtable run-process drop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: target ( -- target ) `{ ,[ os ] %[ cpu "." split ] } "-" join ;

: factor-binary ( -- name )
  os
  { { "macosx" [ "./Factor.app/Contents/MacOS/factor" ] }
    { "winnt" [ "./factor-nt.exe" ] }
    [ drop "./factor" ] }
  case ;

: git-pull ( -- desc )
  {
    "git"
    "pull"
    "--no-summary"
    "git://factorcode.org/git/factor.git"
    "master"
  } ;

: git-clone ( -- desc ) { "git" "clone" "../factor" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: datestamp ( -- string )
  now `{ ,[ dup timestamp-year   ]
         ,[ dup timestamp-month  ]
         ,[ dup timestamp-day    ]
         ,[ dup timestamp-hour   ]
         ,[     timestamp-minute ] }
  [ pad-00 ] map "-" join ;

VAR: stamp

: enter-build-dir ( -- )
  datestamp >stamp
  "/builds" cd
  stamp> make-directory
  stamp> cd ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: git-id ( -- id )
  { "git" "show" } <process-stream> [ readln ] with-stream " " split second ;

: record-git-id ( -- ) git-id "../git-id" [ . ] with-file-out ;

: make-clean ( -- desc ) { "make" "clean" } ;

: make-vm ( -- )
  `{
     { +arguments+ { "make" ,[ target ] } }
     { +stdout+    "../compile-log" }
     { +stderr+    +stdout+ }
   }
  >hashtable ;

: bootstrap ( -- desc )
  `{
     { +arguments+ {
                     ,[ factor-binary ]
                     ,[ "-i=" my-boot-image-name append ]
                     "-no-user-init"
                   } }
     { +stdout+   "../boot-log" }
     { +stderr+   +stdout+ }
     { +timeout+  ,[ 20 minutes>ms ] }
   } ;

: builder-test ( -- desc ) `{ ,[ factor-binary ] "-run=builder.test" } ;
  
SYMBOL: build-status

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: milli-seconds>time ( n -- string )
  1000 /i 60 /mod >r 60 /mod r> 3array [ pad-00 ] map ":" join ;

: eval-file ( file -- obj ) <file-reader> contents eval ;
  
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cat ( file -- ) <file-reader> contents print ;

: run-or-bail ( desc quot -- )
  [ [ try-process ] curry ]
  [ [ throw       ] curry ]
  bi*
  recover ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (build) ( -- )

  enter-build-dir

  "report" [

    "Build machine:   " write host-name print
    "Build directory: " write cwd       print

    git-clone [ "git clone failed" print ] run-or-bail

    "factor" cd

    record-git-id

    make-clean run-process drop

    make-vm [ "vm compile error" print "../compile-log" cat ] run-or-bail

    [ my-arch download-image ] [ "Image download error" print throw ] recover

    ! bootstrap [ "Bootstrap error" print "../boot-log" cat ] run-or-bail

!     bootstrap
!       <process-stream> dup dispose process-stream-process wait-for-process
!     zero? not
!       [ "Bootstrap error" print "../boot-log" cat "bootstrap error" throw ]
!     when

    [
      bootstrap
        <process-stream> dup dispose process-stream-process wait-for-process
      zero? not
        [ "bootstrap non-zero" throw ]
      when
    ]
    [ "Bootstrap error" print "../boot-log" cat "bootstrap" throw ]
    recover
        
    [ builder-test try-process ]
    [ "Builder test error" print throw ]
    recover

    "Boot time: " write "../boot-time" eval-file milli-seconds>time print
    "Load time: " write "../load-time" eval-file milli-seconds>time print
    "Test time: " write "../test-time" eval-file milli-seconds>time print

    "Did not pass load-everything: " print "../load-everything-vocabs" cat
    "Did not pass test-all: "        print "../test-all-vocabs"        cat

    "Benchmarks: " print
    "../benchmarks" [ stdio get contents eval ] with-file-in benchmarks.

  ] with-file-out ;

: build ( -- )
  [ (build) ] [ drop ] recover
  "report" "../report" email-file ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: updates-available? ( -- ? )
  git-id
  git-pull run-process drop
  git-id
  = not ;

: build-loop ( -- )
  [
    "/builds/factor" cd
    updates-available?
      [ build ]
    when
  ]
  [ drop ]
  recover
  5 minutes>ms sleep
  build-loop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: build-loop