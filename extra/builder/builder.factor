
USING: kernel io io.files io.launcher hashtables tools.deploy.backend
       system continuations namespaces sequences splitting math.parser
       prettyprint tools.time calendar bake vars http.client
       combinators ;

IN: builder

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

! : target ( -- target )
!   { { [ os "windows" = ] [ "windows-nt-x86-32" ] }
!     { [ t ]              [ `{ ,[ os ] %[ cpu "." split ] } "-" join ] } }
!   cond ;

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
    "git://factorcode.org/git/factor.git"
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

  { "git" "show" } <process-stream>
  [ readln ] with-stream
  " " split second
  "../git-id" <file-writer> [ print ] with-stream

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
  >hashtable
  [ run-process process-status ]
  benchmark nip "../boot-time" <file-writer> [ . ] with-stream
  0 =
  [ ]
  [
    "builder: bootstrap" "../boot-log" email-file
    "builder: bootstrap" throw
  ] if

!   `{
!      { +arguments+
!        { ,[ factor-binary ] "-e=USE: tools.browser load-everything" } }
!      { +stdout+    "../load-everything-log" }
!      { +stderr+    +stdout+ }
!    }
!   >hashtable [ run-process process-status ] benchmark nip
!   "../load-everything-time" <file-writer> [ . ] with-stream
!   0 =
!   [ ]
!   [
!     "builder: load-everything" "../load-everything-log" email-file
!     "builder: load-everything" throw
!   ] if ;

  `{ ,[ factor-binary ] "-run=builder.load-everything" } run-process drop
  "../load-everything-log" exists?
  [ "builder: load-everything" "../load-everything-log" email-file ]
  when

  ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: build