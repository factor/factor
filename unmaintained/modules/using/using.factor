! Copyright (C) 2009 Sam Anklesaria.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel modules.rpc peg peg-lexer peg.ebnf sequences
strings vocabs.parser ;
IN: modules.using

EBNF: modulize
tokenpart = (!(':').)+ => [[ >string ]]
s = ':' => [[ drop ignore ]]
rpc = tokenpart s s tokenpart => [[ first2 remote-vocab ]]
remote = tokenpart s tokenpart => [[ first2 remote-load ]]
module = rpc | remote | tokenpart
;EBNF

ON-BNF: USING*:
tokenizer = <foreign factor>
sym = !(";"|"}"|"=>"|"EXCEPT").
modspec = sym => [[ modulize ]]
qualified-with = modspec sym => [[ first2 add-qualified ignore ]]
qualified = modspec => [[ dup add-qualified ignore ]]
from = modspec "=>" sym+ => [[ first3 nip add-words-from ignore ]]
exclude = modspec "EXCEPT" sym+ => [[ first3 nip add-words-excluding ignore ]]
rename = modspec sym "=>" sym => [[ first4 nip swapd add-renamed-word ignore ]]
long = "{" ( from | exclude | rename | qualified-with | qualified ) "}" => [[ drop ignore ]]
short = modspec => [[ use-vocab ignore ]]
wordSpec = long | short
using = wordSpec+ ";" => [[ drop ignore ]]
;ON-BNF