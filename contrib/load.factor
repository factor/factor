USING: kernel parser sequences ;
{ 
    "coroutines"
    "dlists"
    "process"
    "splay-trees"
} [ "/contrib/" swap ".factor" append3 run-resource ] each

{
  "cairo"
  "concurrency"
  "math"
  "crypto"
  "aim"
  "gap-buffer"
  "httpd"
  "units"
  "sqlite"
  "postgresql"
  "random-tester"
} [ "/contrib/" swap "/load.factor" append3 run-resource ] each
