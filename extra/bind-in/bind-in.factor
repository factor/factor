
USING: kernel parser lexer locals.private ;

IN: bind-in

! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

: ->
  "[" parse-tokens make-locals dup push-locals
  \ ] (parse-lambda) <lambda>
  parsed-lambda
  \ call parsed ; parsing