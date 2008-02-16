USING: unicode.syntax unicode.data unicode.breaks
unicode.normalize unicode.case unicode.categories
parser ;
IN: unicode

! For now: convenience to load all Unicode vocabs

[ name>char [ "Invalid character" throw ] unless* ]
name>char-hook set-global
