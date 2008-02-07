
USING: kernel io io.files io.launcher hashtables tools.deploy.backend
       system continuations namespaces sequences splitting math.parser
       prettyprint tools.time calendar bake vars http.client
       combinators ;

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

: email-file ( subject file -- )
  `{
    { +stdin+ , }
    { +arguments+ { "mutt" "-s" , %[ builder-recipients get ] } }
  }
  >hashtable run-process drop ;

: email-string ( subject -- )
  `{ "mutt" "-s" , %[ builder-recipients get ] }
  [ ] with-process-stream drop ;

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

: build ( -- )

  datestamp >stamp

  "/builds/factor" cd
  
  {
    "git"
    "pull"
    "--no-summary"
    ! "git://factorcode.org/git/factor.git"
    "http://dharmatech.onigirihouse.com/factor.git"
    "master"
  }
  run-process process-status
  0 =
  [ ]
  [
    "builder: git pull" email-string
    "builder: git pull" throw
  ]
  if

  "/builds/" stamp> append make-directory
  "/builds/" stamp> append cd

  { "git" "clone" "../factor" } run-process drop

  "factor" cd

  { "git" "show" } <process-stream> [ readln ] with-stream " " split second
  "../git-id" log-object

  { "make" "clean" } run-process drop

  `{
     { +arguments+ { "make" ,[ target ] } }
     { +stdout+    "../compile-log" }
     { +stderr+    +stdout+ }
   }
  >hashtable run-process process-status
  0 =
  [ ]
  [
    "builder: vm compile" "../compile-log" email-file
    "builder: vm compile" throw
  ] if

  [ "http://factorcode.org/images/latest/" boot-image-name append download ]
  [ "builder: image download" email-string ]
  recover

  `{
     { +arguments+ {
                     ,[ factor-binary ]
                     ,[ "-i=" boot-image-name append ]
                     "-no-user-init"
                   } }
     { +stdout+   "../boot-log" }
     { +stderr+   +stdout+ }
   }
  >hashtable [ run-process ] "../boot-time" log-runtime process-status
  0 =
  [ ]
  [
    "builder: bootstrap" "../boot-log" email-file
    "builder: bootstrap" throw
  ] if

  `{ ,[ factor-binary ] "-run=builder.test" } run-process drop
  
  "../load-everything-log" exists?
  [ "builder: load-everything" "../load-everything-log" email-file ]
  when

  "../failing-tests" exists?
  [ "builder: failing tests" "../failing-tests" email-file ]
  when

  ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: build