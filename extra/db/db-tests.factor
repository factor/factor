IN: db.tests
USING: tools.test db kernel ;

{ 1 0 } [ [ drop ] query-each ] must-infer-as
{ 1 1 } [ [ ] query-map ] must-infer-as
{ 2 0 } [ [ ] with-db ] must-infer-as
