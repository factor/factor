USING: assocs kernel modules.remote-loading modules.rpc
namespaces peg peg.ebnf peg-lexer sequences vocabs vocabs.parser
strings ;
IN: modules.using

: >qualified ( vocab prefix -- assoc )
    [ vocab-words ] [ 58 suffix ] bi* [ swap [ prepend ] dip ] curry assoc-map ;

: >partial-vocab ( words assoc -- assoc )
    [ dupd at [ no-word-error ] unless* ] curry { } map>assoc ;

: remote-load ( addr vocabspec -- voab ) [ "modules.remote-loading" remote-vocab (use+) ] dip get-vocab ;

: load'em ( vocab words/? -- ) [ swap >partial-vocab ] when* use get push ;

EBNF: modulize
tokenpart = (!(':').)+ => [[ >string ]]
s = ':' => [[ drop ignore ]]
rpc = tokenpart s s tokenpart => [[ first2 remote-vocab ]]
remote = tokenpart s tokenpart => [[ first2 remote-load ]]
plain = tokenpart => [[ load-vocab ]]
module = rpc | remote | plain
;EBNF

ON-BNF: USING:
tokenizer = <foreign factor>
sym = !(";"|"}"|"=>").
modspec = sym => [[ modulize ]]
qualified = modspec sym => [[ first2 >qualified ]]
unqualified = modspec => [[ vocab-words ]]
words = ("=>" sym+ )? => [[ [ f ] [ second ] if-empty ]]
long = "{" ( qualified | unqualified ) words "}" => [[ rest first2 load'em ignore ]]
short = modspec => [[ use+ ignore ]]
wordSpec = long | short
using = wordSpec+ ";" => [[ drop ignore ]]
;ON-BNF