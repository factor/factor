
USING: kernel
       io
       io.streams.duplex
       io.sockets
       io.server
       combinators continuations
       namespaces generic threads sequences arrays vars ;

IN: cabal

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

TUPLE: user name ;

: <user> ( client -- user )
user construct-empty
tuck set-delegate
dup [ "name: " write flush readln ] with-stream* over set-user-name ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: users

: init-users ( -- ) V{ } clone >users ;

: show-users ( -- ) users> [ user-name print ] each flush ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VAR: conversation

: init-conversation ( -- ) V{ } clone >conversation ;

: show-conversation ( -- ) conversation> [ print ] each flush ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

VARS: input user ;

: ((send-input)) ( other -- ) [ input> print flush ] with-stream* ;

: (send-input) ( other -- )
[ ((send-input)) ] catch [ print dup stream-close users> delete ] when ;

: send-input ( other -- )
dup duplex-stream-closed? [ users> delete ] [ (send-input) ] if ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: tag-input ( -- ) user> user-name ": " input> 3append >input ;

: log-input ( -- ) input> conversation> push ;

! : send-message ( -- ) tag-input users> >array [ send-input ] each ;

: send-message ( -- ) tag-input log-input users> >array [ send-input ] each ;

: handle-user-loop ( -- )
readln >input
{ { [ input> f eq? ] [ user> users> delete ] }
  { [ input> "/log" = ] [ show-conversation handle-user-loop ] }
  { [ input> "/users" = ] [ show-users handle-user-loop ] }
  { [ t ] [ send-message handle-user-loop ] } }
cond ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : handle-client ( client -- ) <user> dup users> push
! dup [ >user [ handle-user-loop ] with-stream* ] with-scope ;

: handle-client ( client -- )
<user> dup users> push
dup [ >user [ handle-user-loop ] with-stream ] with-scope ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: accept-client-loop ( server -- )
[ accept [ handle-client ] curry in-thread ] keep
accept-client-loop ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

! : start-cabal ( -- )
! init-users
! init-conversation
! 8000 <server> accept-client-loop ;

: start-cabal ( -- )
init-users
init-conversation
8000 internet-server [ inet4? ] find nip <server> accept-client-loop ;

MAIN: start-cabal