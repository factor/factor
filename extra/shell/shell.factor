
USING: kernel words continuations namespaces debugger sequences combinators
       io io.files io.launcher
       accessors multi-methods newfx shell.parser ;

IN: shell

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: cd ( args -- )
  dup empty?
    [ drop home set-current-directory ]
    [ first     set-current-directory ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: pwd ( args -- )
  drop
  current-directory get
  print ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: swords ( -- seq ) { "cd" "pwd" } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

GENERIC: expand ( expr -- expr )

METHOD: expand { single-quoted-expr } expr>> ;

METHOD: expand { double-quoted-expr } expr>> ;

METHOD: expand { object } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: expansion ( command -- command ) [ expand ] map ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: run-incantation ( incantation -- )
  <process>
    over command>> expansion >>command
    over stdin>>             >>stdin
    over stdout>>            >>stdout
  swap background>>
    [ run-detached drop ]
    [ [ try-process ] [ print-error drop ] recover ]
  if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: chant ( incantation -- )
    dup command>> first swords member-of?
      [ command>> unclip "shell" lookup execute ]
      [ run-incantation ]
    if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: prompt ( -- )
  current-directory get write
  " $ " write
  flush ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: shell ( -- )
  prompt
  readln
    {
      { [ dup f = ] [ drop ] }
      { [ dup "exit" = ] [ drop ] }
      { [ dup "" = ] [ drop shell ] }
      { [ dup expr ] [ expr ast>> chant shell ] }
      { [ t ]        [ drop shell ] }
    }
  cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ix ( -- ) shell ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: ix