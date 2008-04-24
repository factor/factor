
USING: kernel namespaces io.files io.launcher bootstrap.image
       builder.util builder.common ;

IN: builder.cleanup

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: builder-debug

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: compress-image ( -- ) { "bzip2" my-boot-image-name } to-strings try-process ;

: delete-child-factor ( -- )
  build-dir [ { "rm" "-rf" "factor" } try-process ] with-directory ;

: cleanup ( -- )
  builder-debug get f =
    [
      "test-log" delete-file
      delete-child-factor
      compress-image
    ]
  when ;

