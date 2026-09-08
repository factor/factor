USING: assocs compiler.errors help.lint io io.files.temp kernel
lint namespaces parser prettyprint sequences system tools.test vocabs vocabs.loader
vocabs.refresh ;

"resource:logs/linux-issues/tmp" current-temp-directory set-global
auto-use? off
{
    "game.input.x11.buttons" "game.input.x11" "boids"
    "bubble-chamber" "gml.viewer" "ui.tools.listener"
} [ require ] each
{ "game.input" "ui.tools.listener" } [ refresh ] each
{ "game.input" "boids" "bubble-chamber" "ui.tools.listener" }
[ test ] each
{
    "game.input" "boids" "bubble-chamber" "gml.viewer"
    "ui.tools.listener"
} [ [ help-lint ] [ lint-vocabs drop ] bi ] each
:test-failures :lint-failures
"TEST FAILURES " write test-failures get length .
"HELP FAILURES " write lint-failures get assoc-size .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get empty?
lint-failures get assoc-empty? and
compiler-errors get assoc-empty? and 0 1 ? exit
