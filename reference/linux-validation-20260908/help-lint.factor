USING: assocs help.lint io kernel namespaces prettyprint system ;
help-lint-all
"HELP FAILURES " write lint-failures get assoc-size . :lint-failures
lint-failures get assoc-empty? 0 1 ? exit
