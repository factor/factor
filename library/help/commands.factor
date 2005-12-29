IN: help
USING: gadgets-listener gadgets-presentations words ;

"Show word" [ word? ] [ help ] \ in-browser define-default-command
"Show term definition" [ term? ] [ help ] \ in-browser define-default-command
"Show article" [ link? ] [ help ] \ in-browser define-default-command
