IN: disjoint-sets.testes
USING: tools.test disjoint-sets namespaces slots.private ;

SYMBOL: +blah+
-405534154 +blah+ 1 set-slot

SYMBOL: uf

[ ] [
    <disjoint-set> uf set
    +blah+ uf get add-atom
    19026 uf get add-atom
    19026 +blah+ uf get equate
] unit-test

[ 2 ] [ 19026 uf get equiv-set-size ] unit-test
