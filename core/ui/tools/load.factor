REQUIRES: core/ui ;

PROVIDE: core/ui/tools
{ +files+ {
    "tools.factor"
    "messages.factor"
    "interactor.factor"
    "listener.factor"
    "walker.factor"
    "browser.factor"
    "help.factor"
    "workspace.factor"
    "search.factor"
    "operations.factor"
    "interactor.facts"
} }
{ +tests+ {
    "test/listener.factor"
    "test/workspace.factor"
} } ;
