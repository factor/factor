USING: strings.parser kernel namespaces ;

USE: unicode.breaks
USE: unicode.case
USE: unicode.categories
USE: unicode.collation
USE: unicode.data
USE: unicode.normalize
USE: unicode.script

[ name>char [ "Invalid character" throw ] unless* ]
name>char-hook set-global
