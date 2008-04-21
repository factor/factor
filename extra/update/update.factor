
USING: kernel system sequences io.files io.launcher bootstrap.image
       http.client
       builder.util builder.release.branch ;

IN: update

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: run-command ( cmd -- ) to-strings try-process ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: git-pull-clean ( -- )
  image parent-directory
    [
      { "git" "pull" "git://factorcode.org/git/factor.git" branch-name }
      run-command
    ]
  with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: remote-clean-image ( -- url )
  "http://factorcode.org/images/clean/" my-boot-image-name append ;

: download-clean-image ( -- ) remote-clean-image download ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: make-clean ( -- ) { gnu-make "clean" } run-command ;
: make       ( -- ) { gnu-make         } run-command ;
: boot       ( -- ) { "./factor" { "-i=" my-boot-image-name } } run-command ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rebuild ( -- )
  image parent-directory
    [
      download-clean-image
      make-clean
      make
      boot
    ]
  with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: update ( -- )
  image parent-directory
    [
      git-id
      git-pull-clean
      git-id
      = not
        [ rebuild ]
      when
    ]
  with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: update