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
! A simple 'to-do list' web application.
!
! Users can register with the system and from there manage a simple
! list of things to do. All data is stored in a directory in the 
! filesystem with the users name.
IN: todo-example
USE: cont-responder
USE: cont-html
USE: stdio
USE: stack
USE: strings
USE: namespaces
USE: inspector
USE: lists
USE: combinators
USE: cont-examples
USE: todo

: simple-todo-page ( title quot -- )
  #! Call the quotation, with all output going to the
  #! body of an html page with the given title.
  <html> [ 
    <head> [ <title> [ swap write ] </title> ] </head> 
    <body> [ call ] </body>
  ] </html> ;

: paragraph ( str -- )
  #! Output the string as an html paragraph
  <p> [ write ] </p> ;

: row ( list -- )
  #! Output an html TR row with each element of the list
  #! being called to produce the output for each TD.
  <tr> [
    [ <td> [ call ] </td> ] each
  ] </tr> ;

: simple-input ( name -- )
  #! Output a simple HTML input field which will have the
  #! specified name.
  <input type= "text" size= "20" name= input/> ;

: button ( label -- )
  #! Output an HTML submit button with the given label.
  <input type= "submit" value= input/> ;

: form ( quot action -- )
  #! Call quot with any output appearing inside an HTML form.
  #! The form is a POST form where the action is as specified.
  <form method= "post" action= form> [ call ] </form> ;

: input-value ( name -- value )
  #! Get the value of the variable "name". If it is f 
  #! return "" else return the value.
  get [ "" ] unless* ;

: register-new-user ( -- )
  #! Get registration details for a new user and add a
  #! todo list form them.
  [ 
    "Register New TODO List"
    [
      [
        "<table>" write
          [ [ "Name:" write ] [ "name" simple-input ] ] row
          [ [ "Password:" write ] [ "password" simple-input ] ] row
        "</table>" write
        "Register" button     
      ] swap form
    ] simple-todo-page
  ] show alist>namespace [
    "name" get dup "password" get 
  ] bind 
  <todo> dup "1" "Set up todo list" <todo-item> add-todo-item
  swap "database-path" get swap ".todo" cat3 store-todo ;

: get-login-information ( -- user password   )
  [
    "Login"
    [      
      <p> [ "Please enter your username and password (" write
            "Click to Register" [ register-new-user ] quot-href
            "):" write
          ] </p>     
      [
        "<table>" write 
          [ [ "Username:" write ] [ "username" simple-input ] ] row
          [ [ "Password:" write ] [ "password" simple-input ] ] row
        "</table>" write
        "Login" button
      ] swap form 
    ] simple-todo-page 
  ] show alist>namespace [ "username" input-value "password" input-value ] bind ;

: get-todo-list ( -- <todo> )
  #! Prompts for a username or password until a valid combination
  #! is entered then returns the <todo> list for that user.
  get-login-information "database-path" get -rot user-exists? [ get-todo-list ] unless* ;

: enter-new-todo-item ( -- <todo-item> )
  #! Enter a new item to the current todo list.
  [
    "Enter New Todo Item"
    [
      [
        "<table>" write
          [ [ "Priority:" write ]    [ "priority" simple-input ] ] row
          [ [ "Description:" write ] [ "description" simple-input ] ] row
        "</table>" write  
        "Add" button
      ] swap form  
    ] simple-todo-page  
  ] show alist>namespace [ 
    "priority" get "description" get <todo-item> 
  ] bind ;

: save-current-todo ( -- )
  #! Save the current todo list
  "todo" get dup "database-path" get swap [ "user" get ] bind ".todo" cat3 store-todo ;

: todo-example ( path -- )
  #! Startup the todo list example using the given path as the 
  #! directory holding the todo files.
  "database-path" set
  get-todo-list "todo" set
  [
    "todo" get [ "user" get ] bind "'s" "To Do list" cat3
    [
      drop
      "todo" get [
	"<table>" write 
          [ [ "Priority" write ] [ "Complete?" write ] [ "Description" write ] ] row
          [
            [ [ "priority" get write ] 
              [ "complete?" get [ "Yes" ] [ "No" ] ifte write ] 
              [ "description" get write ] ] row
          ] items-each-bind         
        "</table>" write
	"Add Item" [ 
          "todo" get enter-new-todo-item add-todo-item save-current-todo
        ] quot-href
      ] bind
    ] simple-todo-page 
  ] show drop ;

"todo" [ drop "todo/" todo-example ] install-cont-responder