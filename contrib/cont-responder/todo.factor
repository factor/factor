! Copyright (C) 2004 Chris Double.
! 
! Redistribution and use in source and binary forms, with or without
! modification, are permitted provided that the following conditions are met:
! 
! 1. Redistributions of source code must retain the above copyright notice,
!    this list of conditions and the following disclaimer.
! 
! 2. Redistributions in binary form must reproduce the above copyright notice,
!    this list of conditions and the following disclaimer in the documentation
!    and/or other materials provided with the distribution.
! 
! THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES,
! INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
! FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
! DEVELOPERS AND CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
! OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
! WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
! OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
! ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!
! Routines for managing a simple "To Do list". A todo list has a 'user', 
! 'password' and list of items. Each item has a priority, description, 
! and indication if it is complete. 
IN: todo
USE: parser
USE: strings
USE: streams
USE: namespaces
USE: lists
USE: math
USE: stdio
USE: kernel
USE: prettyprint
USE: url-encoding
USE: files
USE: hashtables
USE: sequences

: <todo> ( user password -- <todo> )
  #! Create an empty todo list
  <namespace> [
    "password" set
     "user" set
     f "items" set
  ] extend ;

: <todo-item> ( priority description -- )
  #! Create a todo item
  <namespace> [
    "description" set
    "priority" set
    f "complete?" set
  ] extend ;

: add-todo-item ( <todo> <item> -- )
  #! Add the item to the todo list
  swap [
    "items" get swap unit append "items" set
  ] bind ;

: >yes/no ( bool -- str )
  #! Return the string "yes" if the boolean is true, else
  #! return "no".
  "yes" "no" ? ;

: write-item ( <todo-item> -- )
  #! write the item in a manner that can be later re-read
  [
    "complete?" get >yes/no url-encode print
    "priority" get url-encode print
    "description" get url-encode print
  ] bind ;

: write-items ( list -- )
  #! write the todo list items
  dup length .
  [ write-item ] each ;

: write-todo ( <todo> -- )
  #! Write the todo list to the current output stream
  #! in a format that if loaded by the parser will result
  #! in a <todo> again.
  [ 
    "user" get url-encode print
    "password" get url-encode print
    "items" get write-items
  ] bind ;

: store-todo ( <todo> filename -- )
  #! store the todo list in the given file.
  <file-writer> [ write-todo ] with-stream ;

: read-todo ( -- <todo> )
  #! Read a todo list from the current input stream.
  read-line url-decode read-line url-decode <todo> 
  read-line str>number [
    dup
    <namespace> [
      read-line url-decode "yes" = "complete?" set
      read-line url-decode "priority" set
      read-line url-decode "description" set
    ] extend add-todo-item
  ] times ;

: load-todo ( filename -- <todo> )
  <file-reader> [ read-todo ] with-stream ;  

: password-matches? ( password <todo> -- <todo> )
  #! Returns the <todo> if the password matches otherwise
  #! returns false.
  tuck [ "password" get ] bind = [ drop f ] unless ;

: user-exists? ( db-path name password -- <todo> )
  #! Returns a <todo> if a user with the given name exists
  #! otherwise returns false.
  -rot ".todo" cat3 dup exists? [ 
    load-todo password-matches?
  ] [
    2drop f 
  ] ifte ;

: each-bind ( quot list -- )
  [ swap [ bind ] keep ] each drop ;

: items-each-bind ( quot -- )
  #! For each item in the currently bound todo list, call the quotation
  #! with that item bound.
  "items" get each-bind ;

: todo-username ( <todo> -- username )
  #! return the username for the todo list item.
  "user" swap hash ;

: item-priority ( <todo-item> -- priority )
  #! return the priority for the todo list item.
  "priority" swap hash ;

: item-complete? ( <todo-item> -- boolean )
  #! return true if the todo list item is completed.
  "complete?" swap hash ;

: set-item-completed ( <todo-item> -- )
  t "complete?" rot set-hash ;

: item-description ( <todo-item> -- description )
  #! return the description for the todo list item.
  "description" swap hash ;

: priority-comparator ( item1 item2 -- bool )
  #! Return true if item1 is a higher priority than item2
  >r item-priority r> item-priority string> ;
  
: todo-items ( <todo> -- alist )
  #! Return a list of items for the given todo list.
  "items" swap hash [ priority-comparator ] sort ;

: delete-item ( <todo> <todo-item> -- )
  #! Delete the item from the todo list
  swap dup >r todo-items remove r> [ "items" set ] bind ;

: test-todo 
  "user" "password" <todo> 
   dup "1" "item1" <todo-item> add-todo-item
   dup "2" "item2" <todo-item> add-todo-item ;
