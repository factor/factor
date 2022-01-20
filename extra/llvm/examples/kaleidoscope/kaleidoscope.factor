USING: accessors arrays kernel math.parser multiline peg
peg.ebnf sequences strings ;
IN: llvm.examples.kaleidoscope

TUPLE: ast-binop lhs rhs operator ;
TUPLE: ast-name value ;
TUPLE: ast-number value ;
TUPLE: ast-def name params expr ;
TUPLE: ast-unop expr ;
TUPLE: ast-call name args ;
TUPLE: ast-if condition true false ;

EBNF: tokenize-kaleidoscope [=[
Letter            = [a-zA-Z]
Digit             = [0-9]
Digits            = Digit+
SingleLineComment = "#" (!("\n") .)* "\n" => [[ ignore ]]
Space             = [ \t\r\n] | SingleLineComment
Spaces            = Space* => [[ ignore ]]
NameFirst         = Letter
NameRest          = NameFirst | Digit
iName             = NameFirst NameRest* => [[ first2 swap prefix >string ]]
Name              = !(Keyword) iName  => [[ ast-name boa ]]
Number            = Digits:ws '.' Digits:fs => [[ ws "." fs 3array "" concat-as string>number ast-number boa ]]
                  | Digits => [[ >string string>number ast-number boa ]]
Special           = "(" | ")" | "*" | "+" | "/" | "-" | "<" | ">" | ","
Keyword           = ("def" | "extern" | "if" | "then" | "else") !(NameRest)
Tok               = Spaces (Keyword | Name | Number | Special)
Toks              = Tok* Spaces
]=]

EBNF: parse-kaleidoscope [=[
tokenizer         = <foreign tokenize-kaleidoscope Tok>
Name              = . ?[ ast-name?   ]?         => [[ value>> ]]
Number            = . ?[ ast-number? ]?         => [[ value>> ]]
CondOp            = "<" | ">"
AddOp             = "+" | "-"
MulOp             = "*" | "%" | "/"
Unary             = "-" Unary:p                   => [[ p ast-unop boa ]]
                  | PrimExpr
MulExpr           = MulExpr:x MulOp:op Unary:y    => [[ x y op ast-binop boa ]]
                  | Unary
AddExpr           = AddExpr:x AddOp:op MulExpr:y        => [[ x y op ast-binop boa ]]
                  | MulExpr
RelExpr           = RelExpr:x CondOp:op AddExpr:y       => [[ x y op ast-binop boa ]]
                  | AddExpr
CondExpr          = "if" RelExpr:c "then" CondExpr:e1 "else" CondExpr:e2 => [[ c e1 e2 ast-if boa ]]
                  | RelExpr
Args              = (RelExpr ("," RelExpr => [[ second ]])* => [[ first2 swap prefix ]])?
PrimExpr          = "(" CondExpr:e ")"  => [[ e ]]
                  | Name:n "(" Args:a ")"           => [[ n a ast-call boa ]]
                  | Name
                  | Number
SrcElem           = "def" Name:n "(" Name*:fs ")" CondExpr:expr => [[ n fs expr ast-def boa ]]
                  | RelExpr
SrcElems          = SrcElem*
TopLevel          = SrcElems
]=]
