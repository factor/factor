! Copyright (c) 2007 Chris Double.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel base64 http.server crypto.sha2 namespaces assocs
       quotations hashtables combinators splitting sequences
       http.server.responders io  ;
IN: http.basic-authentication

! 'realms' is a hashtable mapping a realm (a string) to 
! either a quotation or a hashtable. The quotation 
! has stack effect ( username sha-256-string -- bool ).
! It should perform the user authentication. 'sha-256-string'
! is the plain text password provided by the user passed through
! 'string>sha-256-string'. If 'realms' maps to a hashtable then
! it is a mapping of usernames to sha-256 hashed passwords. 
!
! 'realms' can be set on a per vhost basis in the vhosts 
! table.
!
! If there are no realms then authentication fails.
SYMBOL: realms
 
: add-realm ( data name  -- )
  #! Add the named realm to the realms table.
  #! 'data' should be a hashtable or a quotation.
  realms get [ H{ } clone dup realms set ] unless* 
  set-at ;

: user-authorized? ( username password realm -- bool )
  realms get dup [
    at {
      { [ dup quotation? ] [ call ] }
      { [ dup hashtable? ] [ swapd at = ] }
      { [ t ] [ 3drop f ] }
    } cond 
  ] [
    3drop drop f
  ] if ;

: authorization-ok? ( realm header -- bool )  
  #! Given the realm and the 'Authorization' header,
  #! authenticate the user.
  dup [
    " " split dup first "Basic" = [
      second base64> ":" split first2 string>sha-256-string rot 
      user-authorized?
    ] [
      2drop f
    ] if   
  ] [
    2drop f
  ] if ;
  
: with-basic-authentication ( realm quot -- )
  #! Check if the user is authenticated in the given realm
  #! to run the specified quotation. If not, use Basic
  #! Authentication to ask for authorization details.
  over "Authorization" "header" get at authorization-ok? [
    nip call
  ] [
    drop "Basic realm=\"" swap "\"" 3append "WWW-Authenticate" associate 
    "401 Unauthorized" response nl 
    "<html><body>Username or Password is invalid</body></html>" write 
  ] if ;



