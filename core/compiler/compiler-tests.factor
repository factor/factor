USING: io.files tools.test sequences namespaces kernel
compiler.units ;

{
    "templates-early"
    "simple"
    "intrinsics"
    "float"
    "generic"
    "ifte"
    "templates"
    "optimizer"
    "redefine"
    "stack-trace"
    "alien"
    "curry"
    "tuples"
}
[ "resource:core/compiler/test/" swap ".factor" 3append ] map
[ run-test ] map
[ failures get push-all ] each
