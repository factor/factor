
USING: hipku tools.test ;

{ "The hungry white ape\naches in the ancient canyon.\nAutumn colors crunch." } [
    "127.0.0.1" >hipku
] unit-test

{ "127.0.0.1" } [
    "The hungry white ape\naches in the ancient canyon.\nAutumn colors crunch."
    hipku>
] unit-test

{ "Chilled apes and blunt seas\nclap dear firm firm grim grim gnomes.\nLarge holes grasp pained mares." } [
    "2001:db8:3333:4444:5555:6666:7777:8888" >hipku
] unit-test

{ "2001:db8:3333:4444:5555:6666:7777:8888" } [
    "Chilled apes and blunt seas\nclap dear firm firm grim grim gnomes.\nLarge holes grasp pained mares."
    hipku>
] unit-test
