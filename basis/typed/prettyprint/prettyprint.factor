USING: definitions kernel locals.definitions see see.private typed words ;
IN: typed.prettyprint

PREDICATE: typed-lambda-word < lambda-word "typed-word" word-prop ;

M: typed-word definer drop \ TYPED: \ ; ;
M: typed-lambda-word definer drop \ TYPED:: \ ; ;

M: typed-word definition "typed-def" word-prop ;
M: typed-word declarations. "typed-word" word-prop declarations. ;

