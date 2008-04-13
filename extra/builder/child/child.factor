
USING: namespaces debugger io.files io.launcher accessors bootstrap.image
       calendar builder.util builder.common ;

IN: builder.child

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-clean ( -- ) { gnu-make "clean" } to-strings try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-vm ( -- )
  <process>
    gnu-make         >>command
    "../compile-log" >>stdout
    +stdout+         >>stderr
  try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: builds-factor-image ( -- img ) builds/factor my-boot-image-name append-path ;

: copy-image ( -- )
  builds-factor-image ".." copy-file-into
  builds-factor-image "."  copy-file-into ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: boot-cmd ( -- cmd )
  { "./factor" { "-i=" my-boot-image-name } "-no-user-init" } to-strings ;

: boot ( -- )
  <process>
    boot-cmd      >>command
    +closed+      >>stdin
    "../boot-log" >>stdout
    +stdout+      >>stderr
    60 minutes    >>timeout
  try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: test-cmd ( -- cmd ) { "./factor" "-run=builder.test" } ;

: test ( -- )
  <process>
    test-cmd      >>command
    +closed+      >>stdin
    "../test-log" >>stdout
    +stdout+      >>stderr
    240 minutes   >>timeout
  try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: (build-child) ( -- )
  make-clean
  make-vm      status-vm   on
  copy-image
  boot         status-boot on
  test         status-test on
               status      on ;

! : build-child ( -- ) "factor" [ (build-child) ] with-directory ;

: build-child ( -- )
  "factor" set-current-directory
    [ (build-child) ] try
  ".." set-current-directory ;
