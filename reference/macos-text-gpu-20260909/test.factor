USING: assocs compiler.errors kernel namespaces prettyprint
sequences tools.test vocabs.refresh ;
"core-graphics" refresh
"core-text" refresh
"ui.render" refresh
"ui.text" refresh
"ui.text.core-text" refresh
"ui.gadgets.editors" refresh
"ui.render" test
"core-text" test
"core-graphics" test
"ui.text" test
"ui.text.core-text" test
"ui.gadgets.line-support" test
"ui.gadgets.editors" test
"ui.backend.cocoa.views" test
"opengl.textures" test
test-failures get .
compiler-errors get .
test-failures get empty? t assert=
compiler-errors get assoc-empty? t assert=
