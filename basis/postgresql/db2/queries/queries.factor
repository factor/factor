! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays db2 db2.connections db2.queries
db2.statements kernel namespaces postgresql.db2
postgresql.db2.connections.private ;
IN: postgresql.db2.queries

M: postgresql-db-connection current-db-name
    db-connection get db>> database>> ;

TUPLE: postgresql-object < sql-object
    table-catalog
    table-schema
    table-name
    table-type
    self-referencing-column-name
    reference-generation
    user-defined-type-catalog
    user-defined-type-schema
    user-defined-type-name
    is-insertable-into
    is-typed
    commit-action ;

TUPLE: postgresql-column < sql-column
    table_catalog table_schema table_name column_name ordinal_position column_default is_nullable data_type character_maximum_length character_octet_length numeric_precision numeric_precision_radix numeric_scale datetime_precision interval_type interval_precision character_set_catalog character_set_schema character_set_name collation_catalog collation_schema collation_name domain_catalog domain_schema domain_name udt_catalog udt_schema udt_name scope_catalog scope_schema scope_name maximum_cardinality dtd_identifier is_self_referencing is_identity identity_generation identity_start identity_increment identity_maximum identity_minimum identity_cycle is_generated generation_expression is_updatable ;

M: postgresql-db-connection sql-object-class postgresql-object ;
M: postgresql-db-connection sql-column-class postgresql-column ;

