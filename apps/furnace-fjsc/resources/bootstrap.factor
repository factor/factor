: alert ( string -- )
  #! Display the string in an alert box
  window { } "" "alert" { "string" } alien-invoke ;

"browser-dom" in

: get-element ( id -- element )
  document { "element" } "" "getElementById" { "string" } alien-invoke ;

: property ( name element -- value )
  alien-property ;

"scratchpad" in
"Bootstrap code loaded" alert