
USING: kernel io io.files io.launcher tools.deploy.backend
       system namespaces sequences splitting math.parser
       unix prettyprint tools.time calendar bake vars ;

IN: builder

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: datestamp ( -- string )
  now `{ ,[ dup timestamp-year   ]
      	 ,[ dup timestamp-month	 ]
	 ,[ dup timestamp-day	 ]
	 ,[ dup timestamp-hour	 ]
	 ,[     timestamp-minute ] }
  [ number>string 2 CHAR: 0 pad-left ] map "-" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: builder-recipients

: quote ( str -- str ) "'" swap "'" 3append ;

: email-file ( subject file -- )
  `{
     "cat"       ,
     "| mutt -s" ,[ quote ]
     "-x"        %[ builder-recipients get ]
   }
   " " join system drop ;
  
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: target ( -- target ) `{ ,[ os ] %[ cpu "." split ] } "-" join ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: stamp

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: build ( -- )

datestamp >stamp

"/builds/factor" cd
"git pull git://factorcode.org/git/factor.git" system
0 =
[ ]
[
  "builder: git pull" "/dev/null" email-file
  "builder: git pull" throw
]
if

"/builds/" stamp> append make-directory
"/builds/" stamp> append cd
"git clone /builds/factor" system drop

"factor" cd

{ "git" "show" } <process-stream>
[ readln ] with-stream
" " split second
"../git-id" <file-writer> [ print ] with-stream

"make clean" system drop

"make " target " > ../compile-log" 3append system
0 =
[ ]
[
  "builder: vm compile" "../compile-log" email-file
  "builder: vm compile" throw
] if

"wget http://factorcode.org/images/latest/" boot-image-name append system
0 =
[ ]
[
  "builder: image download" "/dev/null" email-file
  "builder: image download" throw
] if

[
  "./factor -i=" boot-image-name " -no-user-init > ../boot-log"
  3append
  system
]
benchmark nip
"../boot-time" <file-writer> [ . ] with-stream
0 =
[ ]
[
  "builder: bootstrap" "../boot-log" email-file
  "builder: bootstrap" throw
] if

[
  "./factor -e='USE: tools.browser load-everything' > ../load-everything-log"
  system
] benchmark nip
"../load-everything-time" <file-writer> [ . ] with-stream
0 =
[ ]
[
  "builder: load-everything" "../load-everything-log" email-file
  "builder: load-everything" throw
] if

;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: build