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
! Routines for managing a simple "To Do list". A todo list has a 'user', 'password'
! and list of items. Each item has a priority, description, and indication if it is
! complete. 
IN: todo
USE: parser
USE: stack
USE: strings
USE: streams
USE: namespaces
USE: lists
USE: math
USE: stdio
USE: kernel
USE: prettyprint
USE: unparser
USE: url-encoding


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
    "items" add@
  ] bind ;

: namespace>alist ( namespace -- alist )
  #! Convert a namespace to an alist
  [ vars-values ] bind ;  
  
: print-quoted ( str -- )
  #! Print the string with quotes around it
  "\"" write write "\"" print ;

: write-item ( <todo-item> -- )
  #! write the item in a manner that can be later re-read
  [
    "complete?" get [ "yes" url-encode print ] [ "no" url-encode print ] ifte
    "priority" get url-encode print
    "description" get url-encode print
  ] bind ;

: write-items ( list -- )
  #! write the todo list items
  dup length unparse print
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
  <filecw> [ write-todo ] with-stream ;

: read-todo ( -- <todo> )
  #! Read a todo list from the current input stream.
  read url-decode read url-decode <todo> 
  read str>number [
    dup
    <namespace> [
      read url-decode "yes" = "complete?" set
      read url-decode "priority" set
      read url-decode "description" set
    ] extend add-todo-item
  ] times ;

: load-todo ( filename -- <todo> )
  <filecr> [ read-todo ] with-stream ;  

: password-matches? ( password <todo> -- <todo> )
  #! Returns the <todo> if the password matches otherwise
  #! returns false.
  dup -rot [ "password" get ] bind = [ ] [ drop f ] ifte ;

: user-exists? ( db-path name password -- <todo> )
  #! Returns a <todo> if a user with the given name exists
  #! otherwise returns false.
  -rot ".todo" cat3 dup exists? [ 
    load-todo password-matches?
  ] [
    2drop f 
  ] ifte ;

: items-each-bind ( quot -- )
  #! For each item in the currently bound todo list, call the quotation
  #! with that item bound.
  unit [ bind ] append "items" get swap each ;

: todo-username ( <todo> -- username )
  #! return the username for the todo list item.
  [ "user" get ] bind ;

: item-priority ( <todo-item> -- priority )
  #! return the priority for the todo list item.
  [ "priority" get ] bind ;

: item-complete? ( <todo-item> -- boolean )
  #! return true if the todo list item is completed.
  [ "complete?" get ] bind ;

: set-item-completed ( <todo-item> -- )
  [ t "complete?" set ] bind ;

: item-description ( <todo-item> -- description )
  #! return the description for the todo list item.
  [ "description" get ] bind ;

: priority-comparator ( item1 item2 -- bool )
  #! Return true if item1 is a higher priority than item2
  >r item-priority r> item-priority str-lexi> ;
  
: todo-items ( <todo> -- alist )
  #! Return a list of items for the given todo list.
  [ "items" get ] bind [ priority-comparator ] sort ;

: delete-item ( <todo> <todo-item> -- )
  #! Delete the item from the todo list
  swap dup >r todo-items remove r> [ "items" set ] bind ;

: test-todo 
  "user" "password" <todo> 
   dup "1" "item1" <todo-item> add-todo-item
   dup "2" "item2" <todo-item> add-todo-item ;
