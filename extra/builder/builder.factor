
USING: kernel namespaces sequences splitting system combinators continuations
       parser io io.files io.launcher io.sockets prettyprint threads
       bootstrap.image benchmark vars bake smtp builder.util accessors
       debugger io.encodings.utf8
       calendar
       tools.test
       builder.common
       builder.benchmark
       builder.release ;

IN: builder

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cd ( path -- ) set-current-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: builds/factor ( -- path ) builds "factor" append-path ;
: build-dir     ( -- path ) builds stamp>   append-path ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: prepare-build-machine ( -- )
  builds make-directory
  builds
    [
      { "git" "clone" "git://factorcode.org/git/factor.git" } try-process
    ]
  with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: builds-check ( -- ) builds exists? not [ prepare-build-machine ] when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: git-clone ( -- desc ) { "git" "clone" "../factor" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: enter-build-dir ( -- )
  datestamp >stamp
  builds cd
  stamp> make-directory
  stamp> cd ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: git-id ( -- id )
  { "git" "show" } utf8 <process-stream>
  [ readln ] with-stream " " split second ;

: record-git-id ( -- ) git-id "../git-id" utf8 [ . ] with-file-writer ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: gnu-make ( -- string )
  os { freebsd openbsd netbsd } member?
    [ "gmake" ]
    [ "make"  ]
  if ;

: do-make-clean ( -- ) { gnu-make "clean" } to-strings try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-vm ( -- desc )
  <process>
    { gnu-make } to-strings >>command
    "../compile-log"        >>stdout
    +stdout+                >>stderr ;

: do-make-vm ( -- )
  make-vm [ "vm compile error" print "../compile-log" cat ] run-or-bail ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: copy-image ( -- )
  builds/factor my-boot-image-name append-path ".." copy-file-into
  builds/factor my-boot-image-name append-path "."  copy-file-into ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: bootstrap-cmd ( -- cmd )
  { "./factor" { "-i=" my-boot-image-name } "-no-user-init" } to-strings ;

: bootstrap ( -- desc )
  <process>
    bootstrap-cmd >>command
    +closed+      >>stdin
    "../boot-log" >>stdout
    +stdout+      >>stderr
    60 minutes    >>timeout ;

: do-bootstrap ( -- )
  bootstrap [ "Bootstrap error" print "../boot-log" cat ] run-or-bail ;

: builder-test-cmd ( -- cmd )
  { "./factor" "-run=builder.test" } to-strings ;

: builder-test ( -- desc )
  <process>
    builder-test-cmd >>command
    +closed+         >>stdin
    "../test-log"    >>stdout
    +stdout+         >>stderr
    240 minutes      >>timeout ;

: do-builder-test ( -- )
  builder-test [ "Test error" print "../test-log" 100 cat-n ] run-or-bail ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: build-status

: (build) ( -- )

  builds-check  

  build-status off

  enter-build-dir

  "report" utf8
    [
      "Build machine:   " write host-name             print
      "CPU:             " write cpu                   .
      "OS:              " write os                    .
      "Build directory: " write current-directory get print

      git-clone [ "git clone failed" print ] run-or-bail

      "factor"
        [
          record-git-id
          do-make-clean
          do-make-vm
          copy-image
          do-bootstrap
          do-builder-test
        ]
      with-directory

      "test-log" delete-file

      "git id:          " write "git-id" eval-file print nl

      "Boot time: " write "boot-time" eval-file milli-seconds>time print
      "Load time: " write "load-time" eval-file milli-seconds>time print
      "Test time: " write "test-time" eval-file milli-seconds>time print nl

      "Did not pass load-everything: " print "load-everything-vocabs" cat
      
      "Did not pass test-all: "        print "test-all-vocabs"        cat
                                             "test-failures"          cat
      
      "help-lint results:"             print "help-lint"              cat

      "Benchmarks: " print "benchmarks" eval-file benchmarks.

      nl

      show-benchmark-deltas

      "benchmarks" ".." copy-file-into

      release
    ]
  with-file-writer

  build-status on ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: builder-from

SYMBOL: builder-recipients

: tag-subject ( str -- str ) { "builder@" host-name* ": " , } bake to-string ;

: subject ( -- str ) build-status get [ "report" ] [ "error" ] if tag-subject ;

: send-builder-email ( -- )
  <email>
    builder-from get        >>from
    builder-recipients get  >>to
    subject                 >>subject
    "./report" file>string >>body
  send-email ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: compress-image ( -- ) { "bzip2" my-boot-image-name } to-strings try-process ;

! : build ( -- )
!   [ (build) ] try
!   builds cd stamp> cd
!   [ send-builder-email ] try
!   { "rm" "-rf" "factor" } [ ] run-or-bail
!   [ compress-image ] try ;

: build ( -- )
  [
    (build)
    build-dir
      [
        { "rm" "-rf" "factor" } try-process
        compress-image
      ]
    with-directory
  ]
  try
  send-builder-email ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

USE: bootstrap.image.download

: git-pull ( -- desc )
  {
    "git"
    "pull"
    "--no-summary"
    "git://factorcode.org/git/factor.git"
    "master"
  } ;

: updates-available? ( -- ? )
  git-id
  git-pull try-process
  git-id
  = not ;

: new-image-available? ( -- ? )
  my-boot-image-name need-new-image?
    [ download-my-image t ]
    [ f ]
  if ;

: build-loop ( -- )
  builds-check
  [
    builds/factor
      [
        updates-available? new-image-available? or
          [ build ]
        when
      ]
    with-directory
  ]
  try
  5 minutes sleep
  build-loop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: build-loop
