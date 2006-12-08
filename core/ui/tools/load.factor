REQUIRES: core/ui ;

PROVIDE: core/ui/tools
{ +files+ {
    "tools.factor"
    "messages.factor"
    "listener.factor"
    "walker.factor"
    "browser.factor"
    "help.factor"
    "dataflow.factor"
    "workspace.factor"
    "search.factor"
    "operations.factor"
} }
{ +tests+ {
    "test/listener.factor"
} } ;
