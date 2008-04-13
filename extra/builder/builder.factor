
USING: kernel debugger io.files threads calendar 
       builder.common
       builder.updates
       builder.build ;

IN: builder

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: build-loop ( -- )
  builds-check
  [
    builds/factor set-current-directory
    new-code-available? [ build ] when
  ]
  try
  5 minutes sleep
  build-loop ;

MAIN: build-loop