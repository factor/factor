USING: accessors definitions kernel parser prettyprint prettyprint.backend see ui.operations ;
IN: ui.operations.syntax

SYNTAX: OPERATION:
    scan-word scan-object swap scan-object define-named-operation ;

M: operation-definition definer drop \ OPERATION: f ;
M: operation-definition synopsis* [ definer. ] [ command>> pprint-word ] bi ;
