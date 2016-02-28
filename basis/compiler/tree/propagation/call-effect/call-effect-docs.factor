USING: combinators.private compiler.units debugger effects help.markup
help.syntax kernel quotations words ;
IN: compiler.tree.propagation.call-effect

HELP: already-inlined-quot?
{ $values { "quot" quotation } { "?" boolean } }
{ $description "Some bookkeeping to make sure that crap like [ dup curry call( quot -- ) ] dup curry call( quot -- ) ] doesn't hang the compiler." } ;

HELP: cached-effect-valid?
{ $values { "quot" quotation } { "?" boolean } }
{ $description { $link t } " if the cached effect is valid." } ;

HELP: call-effect-ic
{ $values { "quot" quotation } { "effect" effect } { "inline-cache" inline-cache } }
{ $description "Checks if there is a hit in the call effect inline cache and if so calls the quotation using " { $link call-effect-unsafe } ". If there isn't a hit, the quotation is called in a slow way and the cache is updated." } ;

HELP: call-effect>quot
{ $values { "effect" effect } { "quot" quotation } }
{ $description "Emits a quotation for calling a quotation with the given stack effect." } ;

HELP: call-effect-slow>quot
{ $values { "effect" effect } { "quot" quotation } }
{ $description "Creates a quotation which wraps " { $link call-effect-unsafe } "." } ;

HELP: call-effect-unsafe?
{ $values { "quot" quotation } { "effect" effect } { "?" boolean } }
{ $description "Checks if the given effect is safe with regards to the quotation." } ;

HELP: safe-infer
{ $values { "quot" quotation } { "effect" effect } }
{ $description "Save and restore error variables here, so that we don't pollute words such as " { $link :error } " and " { $link :c } " for the user." } ;

HELP: update-inline-cache
{ $values { "word/quot" { $or word quotation } } { "ic" inline-cache } }
{ $description "Sets the inline caches " { $slot "value" } " to the given word/quot and updates its " { $slot "counter" } " to the value of the " { $link effect-counter } "." } ;

ARTICLE: "compiler.tree.propagation.call-effect" "Expansions of call( and execute( words"
"call( and execute( have complex expansions."
$nl
"If the input quotation is a literal, or built up from curry and compose with terminal quotations literal, it is inlined at the call site."
$nl
"For dynamic call sites, call( uses the following strategy:"
{ $list
  "Inline caching. If the quotation is the same as last time, just call it unsafely"
  "Effect inference. Infer quotation's effect, caching it in the cached-effect slot, and compare it with declaration. If matches, call it unsafely."
  "Fallback. If the above doesn't work, call it and compare the datastack before and after to make sure it didn't mess anything up."
  "Inline caches and cached effects are invalidated whenever a macro is redefined, or a word's effect changes, by comparing a global counter against the counter value last observed. The counter is incremented by compiler.units."
}
$nl
"execute( uses a similar strategy." ;

ABOUT: "compiler.tree.propagation.call-effect"
