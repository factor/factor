! Copyright (C) 2011 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db2.introspection db2.types kernel orm.persistent
orm.tuples postgresql.db2.connections.private ;
IN: postgresql.db2.introspection

TUPLE: postgresql-object schemaname tablename tableowner tablespace
hasindexes hasrules hastriggers ;

PERSISTENT: { postgresql-object "pg_tables" }
    { "schemaname" TEXT }
    { "tablename" TEXT }
    { "tableowner" TEXT }
    { "tablespace" TEXT }
    { "hasindexes" BOOLEAN }
    { "hasrules" BOOLEAN }
    { "hastriggers" BOOLEAN } ;

TUPLE: information-schema-column
    table_catalog
    table_schema
    table_name
    column_name
    ordinal_position
    column_default
    is_nullable
    data_type
    character_maximum_length
    character_octet_length
    numeric_precision
    numeric_precision_radix
    numeric_scale
    datetime_precision
    interval_type
    interval_precision
    character_set_catalog
    character_set_schema
    character_set_name
    collation_catalog
    collation_schema
    collation_name
    domain_catalog
    domain_schema
    domain_name
    udt_catalog
    udt_schema
    udt_name
    scope_catalog
    scope_schema
    scope_name
    maximum_cardinality
    dtd_identifier
    is_self_referencing
    is_identity
    identity_generation
    identity_start
    identity_increment
    identity_maximum
    identity_minimum
    identity_cycle
    is_generated
    generation_expression
    is_updatable ;

PERSISTENT: { information-schema-column "information_schema" "columns" }
    { "table_catalog" VARCHAR }
    { "table_schema" VARCHAR }
    { "table_name" VARCHAR }
    { "column_name" VARCHAR }
    { "ordinal_position" INTEGER }
    { "column_default" CHARACTER }
    { "is_nullable" CHARACTER }
    { "data_type" CHARACTER }
    { "character_maximum_length" INTEGER }
    { "character_octet_length" INTEGER }
    { "numeric_precision" INTEGER }
    { "numeric_precision_radix" INTEGER }
    { "numeric_scale" INTEGER }
    { "datetime_precision" INTEGER }
    { "interval_type" CHARACTER }
    { "interval_precision" CHARACTER }
    { "character_set_catalog" VARCHAR }
    { "character_set_schema" VARCHAR }
    { "character_set_name" VARCHAR }
    { "collation_catalog" VARCHAR }
    { "collation_schema" VARCHAR }
    { "collation_name" VARCHAR }
    { "domain_catalog" VARCHAR }
    { "domain_schema" VARCHAR }
    { "domain_name" VARCHAR }
    { "udt_catalog" VARCHAR }
    { "udt_schema" VARCHAR }
    { "udt_name" VARCHAR }
    { "scope_catalog" VARCHAR }
    { "scope_schema" VARCHAR }
    { "scope_name" VARCHAR }
    { "maximum_cardinality" INTEGER }
    { "dtd_identifier" VARCHAR }
    { "is_self_referencing" CHARACTER }
    { "is_identity" CHARACTER }
    { "identity_generation" CHARACTER }
    { "identity_start" CHARACTER }
    { "identity_increment" CHARACTER }
    { "identity_maximum" CHARACTER }
    { "identity_minimum" CHARACTER }
    { "identity_cycle" CHARACTER }
    { "is_generated" CHARACTER }
    { "generation_expression" CHARACTER }
    { "is_updatable" CHARACTER } ;
    

M: postgresql-db-connection all-tables
    postgresql-object new select-tuples ;

M: postgresql-db-connection table-columns
    information-schema-column new
        swap >>table_name
    select-tuples ;

! M: postgresql-db-connection all-db-objects

! M: postgresql-db-connection all-indices

! M: postgresql-db-connection temporary-db-objects
