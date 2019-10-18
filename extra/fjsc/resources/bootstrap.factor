IN: namespaces
USE: kernel-internals
: with-variables ( ns quot -- )
  swap >n call n> drop ;

"browser-dom" set-in

: elements ( string -- result )
  #! Call JQuery's $ function
  window { "result" } "" "$" { "string" } alien-invoke ;
  
: html ( string -- element ) 
  #! Set the innerHTML of element using jQuery
  { } "" "html" { "string" } alien-invoke ;

: bind-event ( name element quot -- )
  >function swap { } "" "with-variables" { "string" "function" } alien-invoke ;

"scratchpad" set-in

: example1 ( -- )
  "<button id='test'>Press Me</button>" "#playground" elements html ;

: example2 ( -- )
  "click" "#test" elements [ "clicked" alert ] bind-event ;

: example3 ( -- )
  [
    [
      >r "click" "#test" elements r> [ continue ] curry bind-event
      "Waiting for click on button" alert
      continue
    ] callcc0
    drop "Click done!" alert 
  ] callcc0 ;
  
: alert ( string -- )
  #! Display the string in an alert box
  window { } "" "alert" { "string" } alien-invoke ;
