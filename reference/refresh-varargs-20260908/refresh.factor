USING: assocs compiler.errors debugger io kernel namespaces
sequences system vocabs.refresh ;
"Refreshing older image" print flush
refresh-all
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? [ "Refresh left compiler errors" throw ] unless
"Refresh completed without compiler errors" print flush
0 exit
