: alert ( string -- )
  #! Display the string in an alert box
  window { } "" "alert" { "string" } alien-invoke ;

"browser-dom" in

: $ ( string -- result )
  #! Call JQuery's $ function
  window { "result" } "" "$" { "string" } alien-invoke ;
  

"scratchpad" in
