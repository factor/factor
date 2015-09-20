USING: compiler.tree.propagation.copy compiler.tree.propagation.info
compiler.tree.propagation.nodes namespaces tools.test ;
IN: compiler.tree.propagation.nodes.tests


{
    H{ { 1234 "hello" } }
} [
    H{ { 1234 1234 } } copies set
    {
        H{
            { 1234 "hello" }
            { 4321 "stuff" }
        }
    } value-infos set
    { 1234 } extract-value-info
] unit-test
