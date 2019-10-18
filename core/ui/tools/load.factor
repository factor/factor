REQUIRES: core/ui ;

PROVIDE: core/ui/tools
{ +files+ {
    "tools.factor"
    "interactor.factor"
    "listener.factor"
    "traceback.factor"
    "tiles.factor"
    "browser.factor"
    "inspector.factor"
    "walker.factor"
    "help.factor"
    "workspace.factor"
    "search.factor"
    "operations.factor"
    "interactor.facts"
} }
{ +tests+ {
    "test/listener.factor"
    "test/walker.factor"
    "test/search.factor"
    "test/workspace.factor"
} } ;
