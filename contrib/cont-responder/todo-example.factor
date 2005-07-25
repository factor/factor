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
USE: html
USE: io
USE: strings
USE: namespaces
USE: inspector
USE: lists
USE: cont-examples
USE: regexp
USE: prettyprint
USE: todo
USE: math
USE: kernel
USE: sequences
 
: todo-stylesheet ( -- string )
  #! Return the stylesheet for the todo list
  [ 
    "table.list {" %
    "  text-align:center;" %
    "  font-family: Verdana;" %
    "  font-weight: normal;" %
    "  font-size: 11px;" %
    "  color: #404040;" %
    "  background-color: #fafafa;" %
    "  border: 1px #6699cc solid;" %
    "  border-collapse: collapse;" %
    "  boder-spacing: 0px;" %
    "}" %
    "tr.heading {" %
    "  border-bottom: 2px solid #6699cc;" %
    "  border-left: 1px solix #6699cc;" %
    "  background-color: #BEC8D1;" %
    "  text-align: left;" %
    "  text-indent: 0px;" %
    "  font-family: verdana;" %
    "  font-weight: bold;" %
    "  color: #404040;" %
    "}" %
    "tr.item {" %
    "  border-bottom: 1px solid #9cf;" %
    "  border-top: 0px;" %
    "  border-left: 1px solid #9cf;" %
    "  border-right: 0px;" %
    "  text-align: left;" %
    "  text-indent: 2px;" %
    "  font-family: verdana, sans-serif, arial;" %
    "  font-weight: normal;" %
    "  color: #404040;" %
    "  background-color: #fafafa;" %
    "}" %
    "tr.complete {" %
    "  border-bottom: 1px solid #9cf;" %
    "  border-top: 0px;" %
    "  border-left: 1px solid #9cf;" %
    "  border-right: 0px;" %
    "  text-align: left;" %
    "  text-indent: 2px;" %
    "  font-family: verdana, sans-serif, arial;" %
    "  font-weight: normal;" %
    "  color: #404040;" %
    "  background-color: #ccc;" %
    "}" %
    "td.lbl {" %
    "  font-weight: bold; text-align: right;" %
    "}" %
    "tr.required {" %
    "  background: #FCC;" %
    "}" %
    "input:focus {" %
    "  background: yellow;" %
    "}" %
    "textarea:focus {" %
    "  background: yellow;" %
    "}" %
  ] make-string ;

: todo-stylesheet-url ( -- url )
  #! Generate an URL for the stylesheet.
  t [ [ todo-stylesheet write ] show-final ] register-continuation id>url ;

: include-todo-stylesheet ( -- )  
  #! Generate HTML to include the todo stylesheet
  <link rel= "stylesheet" href= todo-stylesheet-url link/> ;

: show-stack-page ( -- )
  #! Debug function to show a page containing the current call stack.
  [ .s ] string-out chars>entities show-message-page ;

: row ( list -- )
  #! Output an html TR row with each element of the list
  #! being called to produce the output for each TD.
  <tr> 
    [ <td> call </td> ] each
  </tr> ;

: styled-row ( class list -- )
  #! Output an html TR row with each element of the list
  #! being called to produce the output for each TD.
  <tr class= swap tr> 
    [ <td> call </td> ] each
  </tr> ;

: simple-input ( name -- )
  #! Output a simple HTML input field which will have the
  #! specified name.
  <input type= "text" size= "20" name= input/> ;

: simple-input-with-value ( name value -- )
  #! Output a simple HTML input field which will have the
  #! specified name and value.
  <input type= "text" size= "20" value= name= input/> ;

: textarea-input ( name -- )
  #! Output a simple HTML textarea field which will have the
  #! specified name.
  <textarea name= rows= "10" cols= "40" textarea> "Enter description here." write </textarea> ;

: textarea-input-with-value ( name value -- )
  #! Output a simple HTML textarea field which will have the
  #! specified name and value.
  <textarea name= swap rows= "10" cols= "40" textarea> write </textarea> ;

: password-input ( name -- )
  #! Output an HTML password input field which will have the
  #! specified name.
  <input type= "password" size= "20" name= input/> ;

: form ( action quot  -- )
  #! Call quot with any output appearing inside an HTML form.
  #! The form is a POST form where the action is as specified.
  <form method= "post" action= swap form> call </form> ;

: input-value ( name -- value )
  #! Get the value of the variable "name". If it is f 
  #! return "" else return the value.
  get [ "" ] unless* ;

: login-form ( url button-text -- )
  #! Write the HTML for an HTML form requesting a username
  #! and password. The 'accept' button has the text given 
  #! in 'button-text'. The form will go to the given URL on
  #! submission.
  swap [
    <table> 
      [ [ "Name:" write ] [ "name" simple-input ] ] row
      [ [ "Password:" write ] [ "password" password-input ] ] row
    </table>
    button     
  ] form ;
   
: registration-page ( submit-url -- )
  #! Write the HTML for the registration page to std output.
  "Register New TODO List" [
    "Enter the username and password for your new todo list:" paragraph
    "Register" login-form
  ] simple-page ;

: valid-username-char ( ch -- b ) 
  #! Return true if the character is valid to appear in a username.
  dup letter? [
    drop t
  ] [
    dup LETTER? [
      drop t
    ] [
      digit? [
        t
      ] [
        f
      ] ifte
    ] ifte
  ] ifte ;

: replace-invalid-username-chars ( str -- str ) 
  #! Return a string with invalid username characters mapped to underscores.
  [ 
    dup valid-username-char [ 
    ] [ 
      drop CHAR: _ 
    ] ifte 
  ] map ;

: is-valid-username? ( username -- bool )
  #! Return true if the username parses correctly
  dup replace-invalid-username-chars = ;

: login-details-valid? ( name password -- )
  #! Ensure that a valid username and password were
  #! entered. In particular, ensure that only alphanumeric
  #! data was entered to prevent security problems by
  #! using .., etc in the name.
  drop is-valid-username? ;
  
: get-registration-details ( -- name password )
  #! Get the registration details from the user putting
  #! the name and password on the stack.
  [ registration-page ] show [
    "name" get "password" get
  ] bind 2dup login-details-valid? [ 
    2drop 
    "Please ensure you enter a username containing letters and numbers only." show-message-page 
    get-registration-details 	
  ] unless ;
   
: get-todo-filename ( database-path <todo> -- filename )
  #! Get the filename containing the todo list details.
  [ swap % todo-username % ".todo" % ] make-string ;
  
: add-default-todo-item ( <todo> -- )
  #! Add a default todo item. This is a workaround for the 
  #! currently hackish method of saving todo lists which can't
  #! handle empty lists.
  "1" "Set up todo list" <todo-item> add-todo-item ;

: init-new-todo ( <todo> -- )
  #! Add the default todo item and store the todo list to
  #! persistent storage.
  dup add-default-todo-item 
  dup "database-path" get swap get-todo-filename store-todo ;

: register-new-user ( -- )
  #! Get registration details for a new user and add a
  #! todo list for them.
  get-registration-details 
  2dup "database-path" get -rot user-exists? [
    2drop
    "That user already exists in the system, sorry. Please use another name."
    show-message-page
    register-new-user
  ] [
    <todo> init-new-todo
    "You have successfully registered your todo list." show-message-page
  ] ifte ;

: login-request-paragraph ( -- )
  #! Display the paragraph requesting the user to login or register.
  <p>  
    "Please enter your username and password (" write
    "Click to Register" [ register-new-user ] quot-href
    "):" write
  </p> ;
  
: get-login-information ( -- user password )
  [
    "Login" [     
      login-request-paragraph 
      "Login" login-form
    ] simple-page 
  ] show [ 
    "name" get "password" get 
  ] bind  ;

: ensure-login-valid ( user password -- user password )
  2dup login-details-valid? [ 
    "Please ensure you enter a username containing letters and numbers only." show-message-page 
    get-login-information 	
  ] unless ;

: get-todo-list ( -- <todo> )
  #! Prompts for a username or password until a valid combination
  #! is entered then returns the <todo> list for that user.
  get-login-information ensure-login-valid 
  "database-path" get -rot user-exists? [ 
    "Sorry, your username or password was incorrect." show-message-page
    get-todo-list 
  ] unless* ;

: write-new-todo-item-form ( url -- )
  #! Display the HTML for a form allowing entry of a 
  #! todo item details.
  [
    <table> 
      <tr class= "required" tr> 
        <td class= "lbl" td> "Priority" write </td>
        <td> "priority" simple-input </td> 
      </tr>
      <tr class= "required" tr> 
        <td class= "lbl" td> "Description" write </td>
        <td> "description" textarea-input </td> 
      </tr>
    </table>
    "Add" button
  ] form ;

: write-edit-todo-item-form ( item url -- )
  #! Display the HTML for a form allowing editing of a 
  #! todo item details.
  swap [
    [   
      <table> 
        <tr class= "required" tr> 
          <td class= "lbl" td> "Priority" write </td>
          <td> "priority" dup get simple-input-with-value  </td> 
        </tr>
        <tr class= "required" tr> 
          <td class= "lbl" td> "Description" write </td>
          <td> "description" dup get textarea-input-with-value </td> 
        </tr>
      </table>
      "Save" button
    ] form 
  ] bind ;
  
: priority-valid? ( string -- bool )
  #! Test the string containing a priority to see if it is 
  #! valid. It should be a single digit from 0-9.
  dup length 1 = [ 0 swap nth digit? ] [ drop f ] ifte ;

: todo-details-valid? ( priority description -- bool )
  #! Return true if a valid priority and description were entered.
  length 0 > [ priority-valid? ] [ drop f ] ifte ;

: get-new-todo-item ( -- <todo-item> )
  #! Enter a new item to the current todo list.
  [
    "Enter New Todo Item" [ include-todo-stylesheet ] [ write-new-todo-item-form ] styled-page  
  ] show [ 
    "priority" get "description" get 
  ] bind 2dup todo-details-valid? [
    <todo-item> 
  ] [
    2drop 
    "Please ensure you enter a Priority from 0-9 and a description." show-message-page
    get-new-todo-item
  ] ifte ;

: write-get-password-form ( url -- )
  #! Display the HTML for a form allowing entry of a 
  #! new password.
  [
    <table> 
      <tr class= "required" tr> 
        <td class= "lbl" td> "Old Password" write </td>
        <td> "old-password" password-input </td> 
      </tr>
      <tr class= "required" tr> 
        <td class= "lbl" td> "New Password" write </td>
        <td> "new-password" password-input </td> 
      </tr>
      <tr class= "required" tr> 
        <td class= "lbl" td> "Verify Password" write </td>
        <td> "verify-password" password-input </td> 
      </tr>
    </table>
    "Change Password" button
  ] form ;

: get-new-password ( <todo> --  password )
  #! Get a new password for the todo list.
  [
    "Enter New Password" [ include-todo-stylesheet ] [ write-get-password-form ] styled-page  
  ] show [ 
    "old-password" get 
    swap password-matches? [
      "new-password" get
      "verify-password" get = [
        "new-password" get        
      ] [
        "Your new password did not match. The password was NOT changed." show-message-page
        f
      ] ifte
    ] [
      "You entered an incorrect old password. The password was NOT changed." show-message-page
      f
    ] ifte
  ] bind ;

: edit-item-details ( item -- )
  #! Allow editing of an existing items details.
  [
    "Edit Item" [ include-todo-stylesheet ] [ write-edit-todo-item-form ] styled-page  
  ] show [ 
    "priority" get "description" get 
  ] bind 2dup todo-details-valid? [
    rot [ "description" set "priority" set ] bind  
  ] [
    drop drop 
    "Please ensure you enter a Priority from 0-9 and a description." show-message-page
    edit-item-details
  ] ifte ;

: save-current-todo ( -- )
  #! Save the current todo list
  "database-path" get "todo" get get-todo-filename "todo" get swap store-todo ;

: lcurry1 ( value quot -- quot )
  #! Return a quotation that when called will have 'value' 
  #! as the first item on the stack.
  cons ;

: write-mark-complete-action ( item -- )
  #! Write out HTML to perform a mark complete
  #! action on an item (or other appropriate
  #! action if already complete).
  dup item-complete? [
    "Delete" swap [ "todo" get swap delete-item save-current-todo ] lcurry1 quot-href
  ] [
    "Complete" swap [ set-item-completed save-current-todo ] lcurry1 quot-href
  ] ifte ;

: write-edit-action ( item -- )
  #! Write out html to allow editing an item.
  "Edit" swap [ edit-item-details save-current-todo ] lcurry1 quot-href ;

: item-class ( <todo-item> -- string )
  #! Return the class to use for displaying the row for the
  #! item.
  item-complete? [ "complete" ] [ "item" ] ifte ;

: write-item-row ( <todo-item> -- )
  #! Write the todo list item as an HTML row.
  dup dup dup dup
  dup item-class [ 
    [ item-priority write ] 
    [ item-complete? [ "Yes" ] [ "No" ] ifte write ] 
    [ item-description write ] 
    [ write-mark-complete-action ]
    [ write-edit-action ] 
  ] styled-row ;

: write-item-table ( <todo> -- )
  #! Write the table of items for the todo list.
  <table> 
    "heading" [ 
      [ "Priority" write ] [ "Complete?" write ] [ "Description" write ] [ "Action" write ] [ bl ] 
    ] styled-row
    todo-items [ write-item-row ] each 
  </table> ;

: do-add-new-item ( -- )
  #! Request a new item from the user and add it to the current todo list.
  "todo" get get-new-todo-item add-todo-item save-current-todo ;

: do-change-password ( -- )
  #! Allow changing the password for the todo list.
  "todo" get get-new-password dup [
    "todo" get [ "password" set ] bind save-current-todo 
    "Your password has been changed." show-message-page 
  ] [
    drop
  ] ifte ;

: show-todo-list ( -- )
  #! Show the current todo list.
  [
    [ "todo" get todo-username % "'s To Do list" % ] make-string
    [ include-todo-stylesheet ]
    [
      "todo" get write-item-table
      [
        [ "Add Item" [ do-add-new-item ] quot-href ]
        [ "Change Password" [ do-change-password ] quot-href ]
      ] horizontal-layout
    ] styled-page 
  ] show-final ;

: todo-example ( path -- )
  #! Startup the todo list example using the given path as the 
  #! directory holding the todo files.
  "database-path" set
  get-todo-list "todo" set
  show-todo-list ;

"todo" [ drop "todo/" todo-example ] install-cont-responder
