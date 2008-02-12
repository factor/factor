
USING: kernel parser io io.files io.launcher io.sockets hashtables math threads
       arrays system continuations namespaces sequences splitting math.parser
       prettyprint tools.time calendar bake vars http.client
       combinators bootstrap.image bootstrap.image.download
       combinators.cleave ;

IN: builder

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: runtime ( quot -- time ) benchmark nip ;

! : log-runtime ( quot file -- )
!   >r runtime r> <file-writer> [ . ] with-stream ;

! : log-object ( object file -- ) <file-writer> [ . ] with-stream ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: datestamp ( -- string )
  now `{ ,[ dup timestamp-year   ]
         ,[ dup timestamp-month  ]
         ,[ dup timestamp-day    ]
         ,[ dup timestamp-hour   ]
         ,[     timestamp-minute ] }
  [ pad-00 ] map "-" join ;

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

! : run-or-notify ( desc message -- )
!   [ [ try-process ]        curry ]
!   [ [ email-string throw ] curry ]
!   bi*
!   recover ;

! : run-or-send-file ( desc message file -- )
!   >r >r [ try-process ]         curry
!   r> r> [ email-file throw ] 2curry
!   recover ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: target ( -- target ) `{ ,[ os ] %[ cpu "." split ] } "-" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: factor-binary ( -- name )
  os
  { { "macosx" [ "./Factor.app/Contents/MacOS/factor" ] }
    { "winnt" [ "./factor-nt.exe" ] }
    [ drop "./factor" ] }
  case ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: stamp

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: git-pull ( -- desc )
  {
    "git"
    "pull"
    "--no-summary"
    "git://factorcode.org/git/factor.git"
    "master"
  } ;

: git-clone ( -- desc ) { "git" "clone" "../factor" } ;

: enter-build-dir ( -- )
  datestamp >stamp
  "/builds" cd
  stamp> make-directory
  stamp> cd ;

: git-id ( -- id )
  { "git" "show" } <process-stream> [ readln ] with-stream " " split second ;

! : record-git-id ( -- ) git-id "../git-id" log-object ;

: record-git-id ( -- ) git-id "../git-id" [ . ] with-file-out ;

: make-clean ( -- desc ) { "make" "clean" } ;

: make-vm ( -- )
  `{
     { +arguments+ { "make" ,[ target ] } }
     { +stdout+    "../compile-log" }
     { +stderr+    +stdout+ }
   }
  >hashtable ;

! : retrieve-boot-image ( -- )
!   [ my-arch download-image ]
!   [ ]
!   [ "builder: image download" email-string ]
!   cleanup
!   flush ;

: bootstrap ( -- desc )
  `{
     { +arguments+ {
                     ,[ factor-binary ]
                     ,[ "-i=" my-boot-image-name append ]
                     "-no-user-init"
                   } }
     { +stdout+   "../boot-log" }
     { +stderr+   +stdout+ }
   }
  >hashtable ;

: builder-test ( -- desc ) `{ ,[ factor-binary ] "-run=builder.test" } ;
  
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: build-status

! : build ( -- )

!   enter-build-dir
  
!   git-clone "git clone error" run-or-notify

!   "factor" cd

!   record-git-id

!   make-clean "make clean error" run-or-notify

!   make-vm "vm compile error" "../compile-log" run-or-send-file

!   retrieve-boot-image

!   bootstrap "bootstrap error" "../boot-log" run-or-send-file

!   builder-test "builder.test fatal error" run-or-notify
  
!   "../load-everything-log" exists?
!   [ "load-everything" "../load-everything-log" email-file ]
!   when

!   "../failing-tests" exists?
!   [ "failing tests" "../failing-tests" email-file ]
!   when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! SYMBOL: report

! : >>>report ( quot -- ) report get swap with-stream* ;

! : file>>>report ( file -- ) [ <file-reader> contents write ] curry >>>report ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : run-or-report ( desc quot -- )
!   [ [ try-process     ] curry ]
!   [ [ >>>report throw ] curry ]
!   bi*
!   recover ;

! : run-or-report-file ( desc quot file -- )
!   [ [ try-process ] curry ]
!   [ [ >>>report ] curry ]
!   [ [ file>>>report throw ] curry ]
!   tri*
!   compose
!   recover ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : ms>minutes ( ms -- minutes ) 1000.0 / 60 / ;

! : bootstrap-minutes ( -- )
!   "../bootstrap-time" <file-reader> contents eval ms>minutes unparse ;

! : min-and-sec ( milliseconds -- str )
!   1000 /i 60 /mod swap
!   `{ ,[ number>string ] " minutes and " ,[ number>string ] " seconds" }
!   concat ;

! : boot-time ( -- string ) "../bootstrap-time"       eval-file min-and-sec ;
! : load-time ( -- string ) "../load-everything-time" eval-file min-and-sec ;
! : test-time ( -- string ) "../test-all-time"        eval-file min-and-sec ;

: milli-seconds>time ( n -- string )
  1000 /i 60 /mod >r 60 /mod r> 3array [ pad-00 ] map ":" join ;

: eval-file ( file -- obj ) <file-reader> contents eval ;
  
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : (build) ( -- )

!   enter-build-dir

!   "report" <file-writer> report set

!   [
!     "Build machine:   " write host-name write nl
!     "Build directory: " write cwd write nl
!   ] >>>report

!   git-clone [ "Builder fatal error: git clone failed" write nl ] run-or-report

!   "factor" cd

!   record-git-id

!   make-clean run-process drop

!   make-vm
!     [ "Builder fatal error: vm compile error" write nl ]
!     "../compile-log"
!   run-or-report-file

!   [ my-arch download-image ]
!     [ [ "Builder fatal error: image download" write nl ] >>>report throw ]
!   recover

!   bootstrap [ "Bootstrap error" write nl ] "../boot-log" run-or-report-file

!   builder-test [ "Builder test error" write nl ] run-or-report

!   [
!     "Bootstrap time: " write boot-time write nl
!     "Load all time:  " write load-time write nl
!     "Test all time:  " write test-time write nl
!   ] >>>report

!   "../load-everything-vocabs" exists?
!     [
!       [ "Did not pass load-everything: " write nl ] >>>report
!       "../load-everything-vocabs" file>>>report
!     ]
!   when

!   "../test-all-vocabs" exists?
!     [
!       [ "Did not pass test-all: " write nl ] >>>report
!       "../test-all-vocabs" file>>>report
!     ]
!   when ;

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

    bootstrap [ "Bootstrap error" print "../boot-log" cat ] run-or-bail

    [ builder-test try-process ]
    [ "Builder test error" print throw ]
    recover

    "Boot time: " write "../boot-time" eval-file milli-seconds>time print
    "Load time: " write "../load-time" eval-file milli-seconds>time print
    "Test time: " write "../test-time" eval-file milli-seconds>time print

    "Did not pass load-everything: " print "../load-everything-vocabs" cat
    "Did not pass test-all: "        print "../test-all-vocabs"        cat

  ] with-file-out ;

: build ( -- )
  [ (build) ] [ drop ] recover
  "report" "../report" email-file ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : send-report ( -- )
!   report get dispose
!   "report" "../report" email-file ;

! : build ( -- )
!   [ (build) ]
!     [ drop ]
!   recover
!   send-report ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: minutes>ms ( min -- ms ) 60 * 1000 * ;

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