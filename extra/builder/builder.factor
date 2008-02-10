
USING: kernel io io.files io.launcher io.sockets hashtables
       system continuations namespaces sequences splitting math.parser
       prettyprint tools.time calendar bake vars http.client
       combinators bootstrap.image bootstrap.image.download
       combinators.cleave ;

IN: builder

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: runtime ( quot -- time ) benchmark nip ;

: log-runtime ( quot file -- )
  >r runtime r> <file-writer> [ . ] with-stream ;

: log-object ( object file -- ) <file-writer> [ . ] with-stream ;

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

: tag-subject ( str -- str ) `{ "builder@" ,[ host-name ] ": " , } concat ;

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

: run-or-notify ( desc message -- )
  [ [ try-process ]        curry ]
  [ [ email-string throw ] curry ]
  bi*
  recover ;

: run-or-send-file ( desc message file -- )
  >r >r [ try-process ]         curry
  r> r> [ email-string throw ] 2curry
  recover ;

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

: record-git-id ( -- )
  { "git" "show" } <process-stream> [ readln ] with-stream " " split second
  "../git-id" log-object ;

: make-clean ( -- desc ) { "make" "clean" } ;

: make-vm ( -- )
  `{
     { +arguments+ { "make" ,[ target ] } }
     { +stdout+    "../compile-log" }
     { +stderr+    +stdout+ }
   }
  >hashtable ;

: retrieve-boot-image ( -- )
  [ my-arch download-image ]
  [ ]
  [ "builder: image download" email-string ]
  cleanup ;

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

: build ( -- )

  "running" build-status set-global

  "/builds/factor" cd

  git-pull "git pull error" run-or-notify

  enter-build-dir
  
  git-clone "git clone error" run-or-notify

  "factor" cd

  record-git-id

  make-clean "make clean error" run-or-notify

  make-vm "vm compile error" "../compile-log" run-or-send-file

  retrieve-boot-image

  bootstrap "bootstrap error" "../boot-log" run-or-send-file

  builder-test "builder.test fatal error" run-or-notify
  
  "../load-everything-log" exists?
  [ "builder: load-everything" "../load-everything-log" email-file ]
  when

  "../failing-tests" exists?
  [ "builder: failing tests" "../failing-tests" email-file ]
  when

  "ready" build-status set-global ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: build