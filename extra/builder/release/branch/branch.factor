
USING: kernel system namespaces sequences prettyprint io.files io.launcher
       bootstrap.image
       builder.util
       builder.common ;

IN: builder.release.branch

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: branch-name ( -- string ) "clean-" platform append ;

: refspec ( -- string ) "master:" branch-name append ;

: push-to-clean-branch ( -- )
  { "git" "push" "factorcode.org:/git/factor.git" refspec }
  to-strings
  try-process ;

: upload-clean-image ( -- )
  {
    "scp"
    my-boot-image-name
    "factorcode.org:/var/www/factorcode.org/newsite/images/clean"
  }
  to-strings
  try-process ;

: (update-clean-branch) ( -- )
  "factor"
    [
      push-to-clean-branch
      upload-clean-image
    ]
  with-directory ;

: update-clean-branch ( -- )
  upload-to-factorcode get
    [ update-clean-branch ]
  when ;
