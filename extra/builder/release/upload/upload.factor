
USING: kernel namespaces sequences arrays io io.files
       builder.util
       builder.common
       builder.release.archive ;

IN: builder.release.upload

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: upload-host

SYMBOL: upload-username

SYMBOL: upload-directory

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: remote-location ( -- dest )
  upload-directory get platform append ;

: remote-archive-name ( -- dest )
  remote-location "/" archive-name 3append ;

: temp-archive-name ( -- dest )
  remote-archive-name ".incomplete" append ;

: upload-command ( -- args )
  "scp"
  archive-name
  [ upload-username get % "@" % upload-host get % ":" % temp-archive-name % ] "" make
  3array ;

: rename-command ( -- args )
  [
    "ssh" ,
    upload-host get ,
    "-l" ,
    upload-username get ,
    "mv" ,
    temp-archive-name ,
    remote-archive-name ,
  ] { } make ;

: upload-temp-file ( -- )
  upload-command [ "Error uploading binary to factorcode" print ] run-or-bail ;

: rename-temp-file ( -- )
  rename-command [ "Error renaming binary on factorcode" print ] run-or-bail ;

: upload ( -- )
  upload-to-factorcode get
    [ upload-temp-file rename-temp-file ]
  when ;
