
USING: kernel namespaces sequences math
       listener io prettyprint sequences.lib fry ;

IN: display-stack

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

SYMBOL: watched-variables

: watch-var ( sym -- ) watched-variables get push ;

: watch-vars ( sym -- ) watched-variables get [ push ] curry each ;

: unwatch-var ( sym -- ) watched-variables get delete ;

: print-watched-variables ( -- )
  watched-variables get length 0 >
    [
      "----------" print
      watched-variables get
        watched-variables get [ unparse ] map longest length 2 +
        '[ [ unparse ": " append , 32 pad-right write ] [ get . ] bi ]
      each

    ]
  when ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: display-stack ( -- )
  V{ } clone watched-variables set
    [
      print-watched-variables
      "----------" print
      .s
      "----------" print
      retainstack reverse stack.
    ]
  listener-hook set ;

