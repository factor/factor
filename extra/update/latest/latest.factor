USING: kernel namespaces system io.files io.pathnames io.directories
bootstrap.image http.client update update.backup update.util ;
IN: update.latest

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: git-pull-master ( -- )
  image parent-directory
    [
      { "git" "pull" "git://factorcode.org/git/factor.git" "master" }
      run-command
    ]
  with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: remote-latest-image ( -- url )
  { "http://factorcode.org/images/latest/" my-boot-image-name } to-string ;

: download-latest-image ( -- ) remote-latest-image download ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: rebuild-latest ( -- )
  image parent-directory
    [
      backup
      download-latest-image
      make-clean
      make
      boot
    ]
  with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: update-latest ( -- )
  image parent-directory
    [
      git-id
      git-pull-master
      git-id
      = not
        [ rebuild-latest ]
      when
    ]
  with-directory ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: update-latest
