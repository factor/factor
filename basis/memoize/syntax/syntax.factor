USING: kernel memoize parser sequences stack-checker ;

IN: memoize.syntax

SYNTAX: MEMO[
    parse-quotation dup infer memoize-quot suffix! ;

SYNTAX: IDENTITY-MEMO[
    parse-quotation dup infer identity-memoize-quot suffix! ;
