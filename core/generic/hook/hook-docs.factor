USING: generic generic.hook generic.single generic.standard help.markup
help.syntax sequences math math.parser effects ;
IN: generic.hook+docs

HELP: hook-combination
{ $class-description
    "Performs hook method combination . See " { $link POSTPONE: HOOK: } "."
} ;

{ standard-combination hook-combination } related-words
