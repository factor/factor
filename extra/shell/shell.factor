
USING: kernel words continuations namespaces debugger sequences combinators
       system io io.files io.launcher sequences.deep
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

METHOD: expand { variable-expr } expr>> os-env ;

METHOD: expand { glob-expr }
  expr>>
  dup "*" =
    [ drop current-directory get directory [ first ] map ]
    [ ]
  if ;

METHOD: expand { object } ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: expansion ( command -- command ) [ expand ] map flatten ;

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

DEFER: shell

: handle ( input -- )
  {
    { [ dup f = ]      [ drop ] }
    { [ dup "exit" = ] [ drop ] }
    { [ dup "" = ]     [ drop shell ] }
    { [ dup expr ]     [ expr ast>> chant shell ] }
    { [ t ]            [ drop "ix: ignoring input" print shell ] }
  }
    cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: shell ( -- )
  prompt
  readln
  handle ;
  
! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ix ( -- ) shell ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

MAIN: ix