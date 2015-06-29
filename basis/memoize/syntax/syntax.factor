USING: kernel memoize parser sequences stack-checker ;

IN: memoize.syntax

SYNTAX: MEMO[ parse-quotation dup infer memoize-quot suffix! ;
