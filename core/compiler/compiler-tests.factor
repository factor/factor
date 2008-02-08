IN: temporary
USING: tools.browser tools.test kernel sequences vocabs ;

"compiler.test" child-vocabs empty? [
    "compiler.test" load-children
    "compiler.test" test
] when
