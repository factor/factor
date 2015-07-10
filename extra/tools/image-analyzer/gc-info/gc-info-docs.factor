USING: assocs help.markup help.syntax vm words ;
IN: tools.image-analyzer.gc-info

ARTICLE: "tools.image-analyzer.gc-info" "GC maps decoder"
"A vocab that disassembles words gc maps. It's useful to have when debugging garbage collection issues." ;

HELP: word>gc-maps
{ $values { "word" word } { "gc-maps" assoc } }
{ $description "Main word of the vocab. Decodes the gc maps for a word into an assoc with the following format:"
  { $list
    "Each key is the return addess of a gc callsite (delta relative to the start of the code block)."
    {
        "Each value is a two-tuple where:"
        { $list
          "The first element is a three-tuple containing the scrub patterns for the datastack, retainstack and gc roots."
          "The second element is a sequence of derived roots for the callsite."
        }
    }
  }
}
{ $examples
  { $unchecked-example
    "USING: effects prettyprint ;"
    "\\ <effect> word>gc-maps ."
    "{ { 153 { { ?{ t } ?{ t t t } ?{ f t t t t } } { } } } }"
  }
} ;

ABOUT: "tools.image-analyzer.gc-info"
