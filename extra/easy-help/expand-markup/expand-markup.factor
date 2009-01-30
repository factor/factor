
USING: accessors arrays kernel lexer locals math namespaces parser
       sequences splitting ;

IN: easy-help.expand-markup

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: scan-one-array ( string -- array rest )
  string-lines
  lexer-factory get call
  [
  [
    \ } parse-until >array
    lexer get line-text>>
    lexer get column>> tail
  ]
  with-lexer
  ]
  with-scope ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: contains-markup? ( string -- ? ) "{ $" swap subseq? ;

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

:: expand-markup ( LINE -- lines )
  
  LINE contains-markup?
    [
    
      [let | N [ "{ $" LINE start ] |

        LINE N head

        LINE N 2 + tail scan-one-array  dup " " head? [ 1 tail ] [ ] if

        [ 2array ] dip

        expand-markup

        append ]
        
    ]
    [ LINE 1array ]
  if ;
