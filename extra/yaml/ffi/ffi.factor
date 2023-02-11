! Copyright (C) 2013 Jon Harper.
! See https://factorcode.org/license.txt for BSD license.
! adapted from "yaml.h" libYAML 0.1.4
! https://pyyaml.org/wiki/LibYAML
USING: alien alien.c-types alien.destructors alien.libraries
alien.syntax classes.struct combinators literals system
alien.libraries.finder ;
IN: yaml.ffi

<<
"libyaml" { "yaml" "yaml-0" "libyaml-0-2" } find-library-from-list cdecl add-library
>>

C-TYPE: FILE

LIBRARY: libyaml

! /**
!  * @defgroup version Version Information
!  * @{
!  */

! /**
!  * Get the library version as a string.
!  *
!  * @returns The function returns the pointer to a static string of the form
!  * @c "X.Y.Z", where @c X is the major version number, @c Y is a minor version
!  * number, and @c Z is the patch version number.
!  */
FUNCTION: c-string
yaml_get_version_string ( )

! /**
!  * Get the library version numbers.
!  *
!  * @param[out]      major   Major version number.
!  * @param[out]      minor   Minor version number.
!  * @param[out]      patch   Patch version number.
!  */
FUNCTION: void
yaml_get_version ( int *major, int *minor, int *patch )

! /** @} */

! /**
!  * @defgroup basic Basic Types
!  * @{
!  */

! /** The character type (UTF-8 octet). */
! libYAML returns it's data as null-terminated UTF-8 string.
! It copies it's input and we can use null-terminated string
! if we give a negative length. So we can use factor's c-string
! for input and output.
TYPEDEF: uchar yaml_char_t

! /** The version directive data. */
STRUCT: yaml_version_directive_t
    { major int }
    { minor int }
;

! /** The tag directive data. */
STRUCT: yaml_tag_directive_t
    { handle c-string }
    { prefix c-string }
;

! /** The stream encoding. */
ENUM: yaml_encoding_t
    YAML_ANY_ENCODING
    YAML_UTF8_ENCODING
    YAML_UTF16LE_ENCODING
    YAML_UTF16BE_ENCODING
;

! /** Line break types. */
ENUM: yaml_break_t
    YAML_ANY_BREAK
    YAML_CR_BREAK
    YAML_LN_BREAK
    YAML_CRLN_BREAK
;

! /** Many bad things could happen with the parser and emitter. */
ENUM: yaml_error_type_t
    YAML_NO_ERROR

    YAML_MEMORY_ERROR

    YAML_READER_ERROR
    YAML_SCANNER_ERROR
    YAML_PARSER_ERROR
    YAML_COMPOSER_ERROR

    YAML_WRITER_ERROR
    YAML_EMITTER_ERROR
;

! /** The pointer position. */
STRUCT: yaml_mark_t
    { index size_t }
    { line size_t }
    { column size_t }
;

! /** @} */

! /**
!  * @defgroup styles Node Styles
!  * @{
!  */

! /** Scalar styles. */
ENUM: yaml_scalar_style_t
    YAML_ANY_SCALAR_STYLE

    YAML_PLAIN_SCALAR_STYLE

    YAML_SINGLE_QUOTED_SCALAR_STYLE
    YAML_DOUBLE_QUOTED_SCALAR_STYLE

    YAML_LITERAL_SCALAR_STYLE
    YAML_FOLDED_SCALAR_STYLE
;

! /** Sequence styles. */
ENUM: yaml_sequence_style_t
    YAML_ANY_SEQUENCE_STYLE

    YAML_BLOCK_SEQUENCE_STYLE
    YAML_FLOW_SEQUENCE_STYLE
;

! /** Mapping styles. */
ENUM: yaml_mapping_style_t
    YAML_ANY_MAPPING_STYLE

    YAML_BLOCK_MAPPING_STYLE
    YAML_FLOW_MAPPING_STYLE
;

! /** @} */

! /**
!  * @defgroup tokens Tokens
!  * @{
!  */

! /** Token types. */
ENUM: yaml_token_type_t
    YAML_NO_TOKEN

    YAML_STREAM_START_TOKEN
    YAML_STREAM_END_TOKEN

    YAML_VERSION_DIRECTIVE_TOKEN
    YAML_TAG_DIRECTIVE_TOKEN
    YAML_DOCUMENT_START_TOKEN
    YAML_DOCUMENT_END_TOKEN

    YAML_BLOCK_SEQUENCE_START_TOKEN
    YAML_BLOCK_MAPPING_START_TOKEN
    YAML_BLOCK_END_TOKEN

    YAML_FLOW_SEQUENCE_START_TOKEN
    YAML_FLOW_SEQUENCE_END_TOKEN
    YAML_FLOW_MAPPING_START_TOKEN
    YAML_FLOW_MAPPING_END_TOKEN

    YAML_BLOCK_ENTRY_TOKEN
    YAML_FLOW_ENTRY_TOKEN
    YAML_KEY_TOKEN
    YAML_VALUE_TOKEN

    YAML_ALIAS_TOKEN
    YAML_ANCHOR_TOKEN
    YAML_TAG_TOKEN
    YAML_SCALAR_TOKEN
;

! /** The token structure. */
! /** The stream start (for @c YAML_STREAM_START_TOKEN). */
STRUCT: stream_start_token_data
    { encoding yaml_encoding_t }
;
! /** The alias (for @c YAML_ALIAS_TOKEN). */
STRUCT: alias_token_data
    { value c-string }
;
! /** The anchor (for @c YAML_ANCHOR_TOKEN). */
STRUCT: anchor_token_data
    { value c-string }
;

! /** The tag (for @c YAML_TAG_TOKEN). */
STRUCT: tag_token_data
    { handle c-string }
    { suffix c-string }
;

! /** The scalar value (for @c YAML_SCALAR_TOKEN). */
STRUCT: scalar_token_data
    { value c-string }
    { length size_t }
    { style yaml_scalar_style_t }
;

! /** The version directive (for @c YAML_VERSION_DIRECTIVE_TOKEN). */
STRUCT: version_directive_token_data
    { major int }
    { minor int }
;

UNION-STRUCT: token_data
  { stream_start stream_start_token_data }
  { alias alias_token_data }
  { anchor anchor_token_data }
  { tag tag_token_data }
  { scalar scalar_token_data }
  { version_directive version_directive_token_data }
;
STRUCT: yaml_token_t

    { type yaml_token_type_t }

    { data token_data }

    { start_mark yaml_mark_t }
    { end_mark yaml_mark_t }
;

! /**
!  * Free any memory allocated for a token object.
!  *
!  * @param[in,out]   token   A token object.
!  */

FUNCTION: void
yaml_token_delete ( yaml_token_t *token )
DESTRUCTOR: yaml_token_delete

! /** @} */

! /**
!  * @defgroup events Events
!  * @{
!  */

! /** Event types. */
ENUM: yaml_event_type_t
    YAML_NO_EVENT

    YAML_STREAM_START_EVENT
    YAML_STREAM_END_EVENT

    YAML_DOCUMENT_START_EVENT
    YAML_DOCUMENT_END_EVENT

    YAML_ALIAS_EVENT
    YAML_SCALAR_EVENT

    YAML_SEQUENCE_START_EVENT
    YAML_SEQUENCE_END_EVENT

    YAML_MAPPING_START_EVENT
    YAML_MAPPING_END_EVENT
;

! /** The event structure. */

! /** The event data. */
! /** The stream parameters (for @c YAML_STREAM_START_EVENT). */
STRUCT: stream_start_event_data
    { encoding yaml_encoding_t }
;

! /** The document parameters (for @c YAML_DOCUMENT_START_EVENT). */
!   /** The list of tag directives. */
    STRUCT: tag_directives_document_start_event_data
        { start yaml_tag_directive_t* }
        { end yaml_tag_directive_t* }
    ;
STRUCT: document_start_event_data
    { version_directive yaml_version_directive_t* }
    { tag_directives tag_directives_document_start_event_data }
    { implicit int }
;

! /** The document end parameters (for @c YAML_DOCUMENT_END_EVENT). */
STRUCT: document_end_event_data
    { implicit int }
;

! /** The alias parameters (for @c YAML_ALIAS_EVENT). */
STRUCT: alias_event_data
    { anchor c-string }
;

! /** The scalar parameters (for @c YAML_SCALAR_EVENT). */
STRUCT: scalar_event_data
    { anchor c-string }
    { tag c-string }
    { value c-string }
    { length size_t }
    { plain_implicit int }
    { quoted_implicit int }
    { style yaml_scalar_style_t }
;

! /** The sequence parameters (for @c YAML_SEQUENCE_START_EVENT). */
STRUCT: sequence_start_event_data
    { anchor c-string }
    { tag c-string }
    { implicit int }
    { style yaml_sequence_style_t }
;

! /** The mapping parameters (for @c YAML_MAPPING_START_EVENT). */
STRUCT: mapping_start_event_data
    { anchor c-string }
    { tag c-string }
    { implicit int }
    { style yaml_mapping_style_t }
;

UNION-STRUCT: event_data
  { stream_start stream_start_event_data }
  { document_start document_start_event_data }
  { document_end document_end_event_data }
  { alias alias_event_data }
  { scalar scalar_event_data }
  { sequence_start sequence_start_event_data }
  { mapping_start mapping_start_event_data }
;

STRUCT: yaml_event_t

    { type yaml_event_type_t }

    { data event_data }

    { start_mark yaml_mark_t }
    { end_mark yaml_mark_t }
;

! /**
!  * Create the STREAM-START event.
!  *
!  * @param[out]      event       An empty event object.
!  * @param[in]       encoding    The stream encoding.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_stream_start_event_initialize ( yaml_event_t *event,
        yaml_encoding_t encoding )

! /**
!  * Create the STREAM-END event.
!  *
!  * @param[out]      event       An empty event object.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_stream_end_event_initialize ( yaml_event_t *event )

! /**
!  * Create the DOCUMENT-START event.
!  *
!  * The @a implicit argument is considered as a stylistic parameter and may be
!  * ignored by the emitter.
!  *
!  * @param[out]      event                   An empty event object.
!  * @param[in]       version_directive       The %YAML directive value or
!  *                                          @c NULL.
!  * @param[in]       tag_directives_start    The beginning of the %TAG
!  *                                          directives list.
!  * @param[in]       tag_directives_end      The end of the %TAG directives
!  *                                          list.
!  * @param[in]       implicit                If the document start indicator is
!  *                                          implicit.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_document_start_event_initialize ( yaml_event_t *event,
        yaml_version_directive_t *version_directive,
        yaml_tag_directive_t *tag_directives_start,
        yaml_tag_directive_t *tag_directives_end,
        bool implicit )

! /**
!  * Create the DOCUMENT-END event.
!  *
!  * The @a implicit argument is considered as a stylistic parameter and may be
!  * ignored by the emitter.
!  *
!  * @param[out]      event       An empty event object.
!  * @param[in]       implicit    If the document end indicator is implicit.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_document_end_event_initialize ( yaml_event_t *event, bool implicit )

! /**
!  * Create an ALIAS event.
!  *
!  * @param[out]      event       An empty event object.
!  * @param[in]       anchor      The anchor value.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_alias_event_initialize ( yaml_event_t *event, c-string anchor )

! /**
!  * Create a SCALAR event.
!  *
!  * The @a style argument may be ignored by the emitter.
!  *
!  * Either the @a tag attribute or one of the @a plain_implicit and
!  * @a quoted_implicit flags must be set.
!  *
!  * @param[out]      event           An empty event object.
!  * @param[in]       anchor          The scalar anchor or @c NULL.
!  * @param[in]       tag             The scalar tag or @c NULL.
!  * @param[in]       value           The scalar value.
!  * @param[in]       length          The length of the scalar value.
!  * @param[in]       plain_implicit  If the tag may be omitted for the plain
!  *                                  style.
!  * @param[in]       quoted_implicit If the tag may be omitted for any
!  *                                  non-plain style.
!  * @param[in]       style           The scalar style.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_scalar_event_initialize ( yaml_event_t *event,
        c-string anchor, c-string tag,
        c-string value, int length,
        bool plain_implicit, bool quoted_implicit,
        yaml_scalar_style_t style )

! /**
!  * Create a SEQUENCE-START event.
!  *
!  * The @a style argument may be ignored by the emitter.
!  *
!  * Either the @a tag attribute or the @a implicit flag must be set.
!  *
!  * @param[out]      event       An empty event object.
!  * @param[in]       anchor      The sequence anchor or @c NULL.
!  * @param[in]       tag         The sequence tag or @c NULL.
!  * @param[in]       implicit    If the tag may be omitted.
!  * @param[in]       style       The sequence style.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_sequence_start_event_initialize ( yaml_event_t *event,
        c-string anchor, c-string tag, bool implicit,
        yaml_sequence_style_t style )

! /**
!  * Create a SEQUENCE-END event.
!  *
!  * @param[out]      event       An empty event object.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_sequence_end_event_initialize ( yaml_event_t *event )

! /**
!  * Create a MAPPING-START event.
!  *
!  * The @a style argument may be ignored by the emitter.
!  *
!  * Either the @a tag attribute or the @a implicit flag must be set.
!  *
!  * @param[out]      event       An empty event object.
!  * @param[in]       anchor      The mapping anchor or @c NULL.
!  * @param[in]       tag         The mapping tag or @c NULL.
!  * @param[in]       implicit    If the tag may be omitted.
!  * @param[in]       style       The mapping style.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_mapping_start_event_initialize ( yaml_event_t *event,
        c-string anchor, c-string tag, bool implicit,
        yaml_mapping_style_t style )

! /**
!  * Create a MAPPING-END event.
!  *
!  * @param[out]      event       An empty event object.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_mapping_end_event_initialize ( yaml_event_t *event )

! /**
!  * Free any memory allocated for an event object.
!  *
!  * @param[in,out]   event   An event object.
!  */

FUNCTION: void
yaml_event_delete ( yaml_event_t *event )
DESTRUCTOR: yaml_event_delete

! /** @} */

! /**
!  * @defgroup nodes Nodes
!  * @{
!  */

! /** The tag @c !!null with the only possible value: @c null. */
CONSTANT:  YAML_NULL_TAG       "tag:yaml.org,2002:null"
! /** The tag @c !!bool with the values: @c true and @c falce. */
CONSTANT:  YAML_BOOL_TAG       "tag:yaml.org,2002:bool"
! /** The tag @c !!str for string values. */
CONSTANT:  YAML_STR_TAG        "tag:yaml.org,2002:str"
! /** The tag @c !!int for integer values. */
CONSTANT:  YAML_INT_TAG        "tag:yaml.org,2002:int"
! /** The tag @c !!float for float values. */
CONSTANT:  YAML_FLOAT_TAG      "tag:yaml.org,2002:float"
! /** The tag @c !!timestamp for date and time values. */
CONSTANT:  YAML_TIMESTAMP_TAG  "tag:yaml.org,2002:timestamp"

! /** The tag @c !!seq is used to denote sequences. */
CONSTANT:  YAML_SEQ_TAG        "tag:yaml.org,2002:seq"
! /** The tag @c !!map is used to denote mapping. */
CONSTANT:  YAML_MAP_TAG        "tag:yaml.org,2002:map"

! /** The default scalar tag is @c !!str. */
CONSTANT:  YAML_DEFAULT_SCALAR_TAG     $ YAML_STR_TAG
! /** The default sequence tag is @c !!seq. */
CONSTANT:  YAML_DEFAULT_SEQUENCE_TAG   $ YAML_SEQ_TAG
! /** The default mapping tag is @c !!map. */
CONSTANT:  YAML_DEFAULT_MAPPING_TAG    $ YAML_MAP_TAG

! /** Node types. */
ENUM: yaml_node_type_t
    YAML_NO_NODE

    YAML_SCALAR_NODE
    YAML_SEQUENCE_NODE
    YAML_MAPPING_NODE
;

! /** The forward definition of a document node structure. */
! typedef struct yaml_node_s yaml_node_t;

! /** An element of a sequence node. */
TYPEDEF: int yaml_node_item_t

! /** An element of a mapping node. */
STRUCT: yaml_node_pair_t
    { key int }
    { value int }
;

! /** The node structure. */
        ! /** The scalar parameters (for @c YAML_SCALAR_NODE). */
        STRUCT: scalar_node_data
            { value c-string }
            { length size_t }
            { style yaml_scalar_style_t }
        ;

        ! /** The sequence parameters (for @c YAML_SEQUENCE_NODE). */
            ! /** The stack of sequence items. */
            STRUCT: sequence_node_data_items
                { start yaml_node_item_t* }
                { end yaml_node_item_t* }
                { top yaml_node_item_t* }
            ;
        STRUCT: sequence_node_data
            { items sequence_node_data_items }
            { style yaml_sequence_style_t }
        ;

        ! /** The mapping parameters (for @c YAML_MAPPING_NODE). */
            ! /** The stack of mapping pairs (key, value). */
            STRUCT: mapping_node_data_pairs
                { start yaml_node_pair_t* }
                { end yaml_node_pair_t* }
                { top yaml_node_pair_t* }
            ;
        STRUCT: mapping_node_data
            { pairs mapping_node_data_pairs }
            { style yaml_mapping_style_t }
        ;
  UNION-STRUCT: node_data
    { scalar scalar_node_data }
    { sequence sequence_node_data }
    { mapping mapping_node_data }
  ;

STRUCT: yaml_node_t

    { type yaml_node_type_t }

    { tag c-string }

    { data node_data }

    { start_mark yaml_mark_t }
    { end_mark yaml_mark_t }

;

! /** The document structure. */
    ! /** The document nodes. */
    STRUCT: yaml_document_nodes
        { start yaml_node_t* }
        { end yaml_node_t* }
        { top yaml_node_t* }
    ;

    ! /** The list of tag directives. */
    STRUCT: yaml_document_tag_directives
        { start yaml_tag_directive_t* }
        { end yaml_tag_directive_t* }
    ;

STRUCT: yaml_document_t

    { nodes yaml_document_nodes }

    { version_directive yaml_version_directive_t* }

    { tag_directives yaml_document_tag_directives }

    { start_implicit int }
    { end_implicit int }

    { start_mark yaml_mark_t }
    { end_mark yaml_mark_t }

;

! /**
!  * Create a YAML document.
!  *
!  * @param[out]      document                An empty document object.
!  * @param[in]       version_directive       The %YAML directive value or
!  *                                          @c NULL.
!  * @param[in]       tag_directives_start    The beginning of the %TAG
!  *                                          directives list.
!  * @param[in]       tag_directives_end      The end of the %TAG directives
!  *                                          list.
!  * @param[in]       start_implicit          If the document start indicator is
!  *                                          implicit.
!  * @param[in]       end_implicit            If the document end indicator is
!  *                                          implicit.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_document_initialize ( yaml_document_t *document,
        yaml_version_directive_t *version_directive,
        yaml_tag_directive_t *tag_directives_start,
        yaml_tag_directive_t *tag_directives_end,
        bool start_implicit, bool end_implicit )

! /**
!  * Delete a YAML document and all its nodes.
!  *
!  * @param[in,out]   document        A document object.
!  */

FUNCTION: void
yaml_document_delete ( yaml_document_t *document )
DESTRUCTOR: yaml_document_delete

! /**
!  * Get a node of a YAML document.
!  *
!  * The pointer returned by this function is valid until any of the functions
!  * modifying the documents are called.
!  *
!  * @param[in]       document        A document object.
!  * @param[in]       index           The node id.
!  *
!  * @returns the node objct or @c NULL if @c node_id is out of range.
!  */

FUNCTION: yaml_node_t*
yaml_document_get_node ( yaml_document_t *document, int index )

! /**
!  * Get the root of a YAML document node.
!  *
!  * The root object is the first object added to the document.
!  *
!  * The pointer returned by this function is valid until any of the functions
!  * modifying the documents are called.
!  *
!  * An empty document produced by the parser signifies the end of a YAML
!  * stream.
!  *
!  * @param[in]       document        A document object.
!  *
!  * @returns the node object or @c NULL if the document is empty.
!  */

FUNCTION: yaml_node_t*
yaml_document_get_root_node ( yaml_document_t *document )

! /**
!  * Create a SCALAR node and attach it to the document.
!  *
!  * The @a style argument may be ignored by the emitter.
!  *
!  * @param[in,out]   document        A document object.
!  * @param[in]       tag             The scalar tag.
!  * @param[in]       value           The scalar value.
!  * @param[in]       length          The length of the scalar value.
!  * @param[in]       style           The scalar style.
!  *
!  * @returns the node id or @c 0 on error.
!  */

FUNCTION: int
yaml_document_add_scalar ( yaml_document_t *document,
        c-string tag, c-string value, int length,
        yaml_scalar_style_t style )

! /**
!  * Create a SEQUENCE node and attach it to the document.
!  *
!  * The @a style argument may be ignored by the emitter.
!  *
!  * @param[in,out]   document    A document object.
!  * @param[in]       tag         The sequence tag.
!  * @param[in]       style       The sequence style.
!  *
!  * @returns the node id or @c 0 on error.
!  */

FUNCTION: int
yaml_document_add_sequence ( yaml_document_t *document,
        c-string tag, yaml_sequence_style_t style )

! /**
!  * Create a MAPPING node and attach it to the document.
!  *
!  * The @a style argument may be ignored by the emitter.
!  *
!  * @param[in,out]   document    A document object.
!  * @param[in]       tag         The sequence tag.
!  * @param[in]       style       The sequence style.
!  *
!  * @returns the node id or @c 0 on error.
!  */

FUNCTION: int
yaml_document_add_mapping ( yaml_document_t *document,
        c-string tag, yaml_mapping_style_t style )

! /**
!  * Add an item to a SEQUENCE node.
!  *
!  * @param[in,out]   document    A document object.
!  * @param[in]       sequence    The sequence node id.
!  * @param[in]       item        The item node id.
! *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_document_append_sequence_item ( yaml_document_t *document,
        int sequence, int item )

! /**
!  * Add a pair of a key and a value to a MAPPING node.
!  *
!  * @param[in,out]   document    A document object.
!  * @param[in]       mapping     The mapping node id.
!  * @param[in]       key         The key node id.
!  * @param[in]       value       The value node id.
! *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_document_append_mapping_pair ( yaml_document_t *document,
        int mapping, int key, int value )

! /** @} */

! /**
!  * @defgroup parser Parser Definitions
!  * @{
!  */

! /**
!  * The prototype of a read handler.
!  *
!  * The read handler is called when the parser needs to read more bytes from the
!  * source.  The handler should write not more than @a size bytes to the @a
!  * buffer.  The number of written bytes should be set to the @a length variable.
!  *
!  * @param[in,out]   data        A pointer to an application data specified by
!  *                              yaml_parser_set_input().
!  * @param[out]      buffer      The buffer to write the data from the source.
!  * @param[in]       size        The size of the buffer.
!  * @param[out]      size_read   The actual number of bytes read from the source.
!  *
!  * @returns On success, the handler should return @c 1.  If the handler failed,
!  * the returned value should be @c 0.  On EOF, the handler should set the
!  * @a size_read to @c 0 and return @c 1.
!  */

CALLBACK: bool yaml_read_handler_t ( void *data,  uchar *buffer, size_t size,
         size_t *size_read )

! /**
!  * This structure holds information about a potential simple key.
!  */

STRUCT: yaml_simple_key_t
    { possible int }

    { required int }

    { token_number size_t }

    { mark yaml_mark_t }
;

! /**
!  * The states of the parser.
!  */
ENUM: yaml_parser_state_t
    YAML_PARSE_STREAM_START_STATE
    YAML_PARSE_IMPLICIT_DOCUMENT_START_STATE
    YAML_PARSE_DOCUMENT_START_STATE
    YAML_PARSE_DOCUMENT_CONTENT_STATE
    YAML_PARSE_DOCUMENT_END_STATE
    YAML_PARSE_BLOCK_NODE_STATE
    YAML_PARSE_BLOCK_NODE_OR_INDENTLESS_SEQUENCE_STATE
    YAML_PARSE_FLOW_NODE_STATE
    YAML_PARSE_BLOCK_SEQUENCE_FIRST_ENTRY_STATE
    YAML_PARSE_BLOCK_SEQUENCE_ENTRY_STATE
    YAML_PARSE_INDENTLESS_SEQUENCE_ENTRY_STATE
    YAML_PARSE_BLOCK_MAPPING_FIRST_KEY_STATE
    YAML_PARSE_BLOCK_MAPPING_KEY_STATE
    YAML_PARSE_BLOCK_MAPPING_VALUE_STATE
    YAML_PARSE_FLOW_SEQUENCE_FIRST_ENTRY_STATE
    YAML_PARSE_FLOW_SEQUENCE_ENTRY_STATE
    YAML_PARSE_FLOW_SEQUENCE_ENTRY_MAPPING_KEY_STATE
    YAML_PARSE_FLOW_SEQUENCE_ENTRY_MAPPING_VALUE_STATE
    YAML_PARSE_FLOW_SEQUENCE_ENTRY_MAPPING_END_STATE
    YAML_PARSE_FLOW_MAPPING_FIRST_KEY_STATE
    YAML_PARSE_FLOW_MAPPING_KEY_STATE
    YAML_PARSE_FLOW_MAPPING_VALUE_STATE
    YAML_PARSE_FLOW_MAPPING_EMPTY_VALUE_STATE
    YAML_PARSE_END_STATE
;

! /**
!  * This structure holds aliases data.
!  */

STRUCT: yaml_alias_data_t
    { anchor c-string }
    { index int }
    { mark yaml_mark_t }
;

! /**
!  * The parser structure.
!  *
!  * All members are internal.  Manage the structure using the @c yaml_parser_
!  * family of functions.
!  */

    ! /** Standard (string or file) input data. */
        ! /** String input data. */
        STRUCT: string_yaml_parser_input
            { start uchar* }
            { end uchar* }
            { current uchar* }
        ;
    UNION-STRUCT: yaml_parser_input
        { string string_yaml_parser_input }
        { file FILE* }
    ;

    ! /** The working buffer. */
    STRUCT: yaml_parser_buffer
        { start yaml_char_t* }
        { end yaml_char_t* }
        { pointer yaml_char_t* }
        { last yaml_char_t* }
    ;

    ! /** The raw buffer. */
    STRUCT: yaml_parser_raw_buffer
        { start uchar* }
        { end uchar* }
        { pointer uchar* }
        { last uchar* }
    ;

    ! /** The tokens queue. */
    STRUCT: yaml_parser_tokens
        { start yaml_token_t* }
        { end yaml_token_t* }
        { head yaml_token_t* }
        { tail yaml_token_t* }
    ;

    ! /** The indentation levels stack. */
    STRUCT: yaml_parser_indents
        { start int* }
        { end int* }
        { top int* }
    ;

    ! /** The stack of simple keys. */
    STRUCT: yaml_parser_simple_keys
        { start yaml_simple_key_t* }
        { end yaml_simple_key_t* }
        { top yaml_simple_key_t* }
    ;

    ! /** The parser states stack. */
    STRUCT: yaml_parser_states
        { start yaml_parser_state_t* }
        { end yaml_parser_state_t* }
        { top yaml_parser_state_t* }
    ;

    ! /** The stack of marks. */
    STRUCT: yaml_parser_marks
        { start yaml_mark_t* }
        { end yaml_mark_t* }
        { top yaml_mark_t* }
    ;

    ! /** The list of TAG directives. */
    STRUCT: yaml_parser_tag_directives
        { start yaml_tag_directive_t* }
        { end yaml_tag_directive_t* }
        { top yaml_tag_directive_t* }
    ;

    ! /** The alias data. */
    STRUCT: yaml_parser_aliases
        { start yaml_alias_data_t* }
        { end yaml_alias_data_t* }
        { top yaml_alias_data_t* }
    ;
STRUCT: yaml_parser_t

    { error yaml_error_type_t }
    { problem c-string }
    { problem_offset size_t }
    { problem_value int }
    { problem_mark yaml_mark_t }
    { context c-string }
    { context_mark yaml_mark_t }

    { read_handler yaml_read_handler_t* }

    { read_handler_data void* }

    { input yaml_parser_input }

    { eof int }

    { buffer yaml_parser_buffer }

    { unread size_t }

    { raw_buffer yaml_parser_raw_buffer }

    { encoding yaml_encoding_t }

    { offset size_t }

    { mark yaml_mark_t }

    { stream_start_produced int }

    { stream_end_produced int }

    { flow_level int }

    { tokens yaml_parser_tokens }

    { tokens_parsed size_t }

    { token_available int }

    { indents yaml_parser_indents }

    { indent int }

    { simple_key_allowed int }

    { simple_keys yaml_parser_simple_keys }

    { states yaml_parser_states }

    { state yaml_parser_state_t }

    { marks yaml_parser_marks }

    { tag_directives yaml_parser_tag_directives }

    { aliases yaml_parser_aliases }

    { document yaml_document_t* }
;

! /**
!  * Initialize a parser.
!  *
!  * This function creates a new parser object.  An application is responsible
!  * for destroying the object using the yaml_parser_delete() function.
!  *
!  * @param[out]      parser  An empty parser object.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_parser_initialize ( yaml_parser_t *parser )

! /**
!  * Destroy a parser.
!  *
!  * @param[in,out]   parser  A parser object.
!  */

FUNCTION: void
yaml_parser_delete ( yaml_parser_t *parser )
DESTRUCTOR: yaml_parser_delete

! /**
!  * Set a string input.
!  *
!  * Note that the @a input pointer must be valid while the @a parser object
!  * exists.  The application is responsible for destroing @a input after
!  * destroying the @a parser.
!  *
!  * @param[in,out]   parser  A parser object.
!  * @param[in]       input   A source data.
!  * @param[in]       size    The length of the source data in bytes.
!  */

FUNCTION: void
yaml_parser_set_input_string ( yaml_parser_t *parser,
        uchar *input, size_t size )

! /**
!  * Set a file input.
!  *
!  * @a file should be a file object open for reading.  The application is
!  * responsible for closing the @a file.
!  *
!  * @param[in,out]   parser  A parser object.
!  * @param[in]       file    An open file.
!  */

FUNCTION: void
yaml_parser_set_input_file ( yaml_parser_t *parser, FILE *file )

! /**
!  * Set a generic input handler.
!  *
!  * @param[in,out]   parser  A parser object.
!  * @param[in]       handler A read handler.
!  * @param[in]       data    Any application data for passing to the read
!  *                          handler.
!  */

FUNCTION: void
yaml_parser_set_input ( yaml_parser_t *parser,
        yaml_read_handler_t *handler, void *data )

! /**
!  * Set the source encoding.
!  *
!  * @param[in,out]   parser      A parser object.
!  * @param[in]       encoding    The source encoding.
!  */

FUNCTION: void
yaml_parser_set_encoding ( yaml_parser_t *parser, yaml_encoding_t encoding )

! /**
!  * Scan the input stream and produce the next token.
!  *
!  * Call the function subsequently to produce a sequence of tokens corresponding
!  * to the input stream.  The initial token has the type
!  * @c YAML_STREAM_START_TOKEN while the ending token has the type
!  * @c YAML_STREAM_END_TOKEN.
!  *
!  * An application is responsible for freeing any buffers associated with the
!  * produced token object using the @c yaml_token_delete function.
!  *
!  * An application must not alternate the calls of yaml_parser_scan() with the
!  * calls of yaml_parser_parse() or yaml_parser_load(). Doing this will break
!  * the parser.
!  *
!  * @param[in,out]   parser      A parser object.
!  * @param[out]      token       An empty token object.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_parser_scan ( yaml_parser_t *parser, yaml_token_t *token )

! /**
!  * Parse the input stream and produce the next parsing event.
!  *
!  * Call the function subsequently to produce a sequence of events corresponding
!  * to the input stream.  The initial event has the type
!  * @c YAML_STREAM_START_EVENT while the ending event has the type
!  * @c YAML_STREAM_END_EVENT.
!  *
!  * An application is responsible for freeing any buffers associated with the
!  * produced event object using the yaml_event_delete() function.
!  *
!  * An application must not alternate the calls of yaml_parser_parse() with the
!  * calls of yaml_parser_scan() or yaml_parser_load(). Doing this will break the
!  * parser.
!  *
!  * @param[in,out]   parser      A parser object.
!  * @param[out]      event       An empty event object.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_parser_parse ( yaml_parser_t *parser, yaml_event_t *event )

! /**
!  * Parse the input stream and produce the next YAML document.
!  *
!  * Call this function subsequently to produce a sequence of documents
!  * constituting the input stream.
!  *
!  * If the produced document has no root node, it means that the document
!  * end has been reached.
!  *
!  * An application is responsible for freeing any data associated with the
!  * produced document object using the yaml_document_delete() function.
!  *
!  * An application must not alternate the calls of yaml_parser_load() with the
!  * calls of yaml_parser_scan() or yaml_parser_parse(). Doing this will break
!  * the parser.
!  *
!  * @param[in,out]   parser      A parser object.
!  * @param[out]      document    An empty document object.
!  *
!  * @return @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_parser_load ( yaml_parser_t *parser, yaml_document_t *document )

! /** @} */

! /**
!  * @defgroup emitter Emitter Definitions
!  * @{
!  */

! /**
!  * The prototype of a write handler.
!  *
!  * The write handler is called when the emitter needs to flush the accumulated
!  * characters to the output.  The handler should write @a size bytes of the
!  * @a buffer to the output.
!  *
!  * @param[in,out]   data        A pointer to an application data specified by
!  *                              yaml_emitter_set_output().
!  * @param[in]       buffer      The buffer with bytes to be written.
!  * @param[in]       size        The size of the buffer.
!  *
!  * @returns On success, the handler should return @c 1.  If the handler failed,
!  * the returned value should be @c 0.
!  */

CALLBACK: bool yaml_write_handler_t ( void *data, uchar *buffer, size_t size )

! /** The emitter states. */
ENUM: yaml_emitter_state_t
    YAML_EMIT_STREAM_START_STATE
    YAML_EMIT_FIRST_DOCUMENT_START_STATE
    YAML_EMIT_DOCUMENT_START_STATE
    YAML_EMIT_DOCUMENT_CONTENT_STATE
    YAML_EMIT_DOCUMENT_END_STATE
    YAML_EMIT_FLOW_SEQUENCE_FIRST_ITEM_STATE
    YAML_EMIT_FLOW_SEQUENCE_ITEM_STATE
    YAML_EMIT_FLOW_MAPPING_FIRST_KEY_STATE
    YAML_EMIT_FLOW_MAPPING_KEY_STATE
    YAML_EMIT_FLOW_MAPPING_SIMPLE_VALUE_STATE
    YAML_EMIT_FLOW_MAPPING_VALUE_STATE
    YAML_EMIT_BLOCK_SEQUENCE_FIRST_ITEM_STATE
    YAML_EMIT_BLOCK_SEQUENCE_ITEM_STATE
    YAML_EMIT_BLOCK_MAPPING_FIRST_KEY_STATE
    YAML_EMIT_BLOCK_MAPPING_KEY_STATE
    YAML_EMIT_BLOCK_MAPPING_SIMPLE_VALUE_STATE
    YAML_EMIT_BLOCK_MAPPING_VALUE_STATE
    YAML_EMIT_END_STATE
;

! /**
!  * The emitter structure.
!  *
!  * All members are internal.  Manage the structure using the @c yaml_emitter_
!  * family of functions.
!  */

    ! /** Standard (string or file) output data. */
        ! /** String output data. */
        STRUCT: yaml_emitter_output_string
            { buffer uchar* }
            { size size_t }
            { size_written size_t* }
        ;

    UNION-STRUCT: yaml_emitter_output
        { string yaml_emitter_output_string }

        { file FILE* }
    ;

    ! /** The working buffer. */
    STRUCT: yaml_emitter_buffer
        { start yaml_char_t* }
        { end yaml_char_t* }
        { pointer yaml_char_t* }
        { last yaml_char_t* }
    ;

    ! /** The raw buffer. */
    STRUCT: yaml_emitter_raw_buffer
        { start uchar* }
        { end uchar* }
        { pointer uchar* }
        { last uchar* }
    ;

    ! /** The stack of states. */
    STRUCT: yaml_emitter_states
        { start yaml_emitter_state_t* }
        { end yaml_emitter_state_t* }
        { top yaml_emitter_state_t* }
    ;

    ! /** The event queue. */
    STRUCT: yaml_emitter_events
        { start yaml_event_t* }
        { end yaml_event_t* }
        { head yaml_event_t* }
        { tail yaml_event_t* }
    ;

    ! /** The stack of indentation levels. */
    STRUCT: yaml_emitter_indents
        { start int* }
        { end int* }
        { top int* }
    ;

    ! /** The list of tag directives. */
    STRUCT: yaml_emitter_tag_directives
        { start yaml_tag_directive_t* }
        { end yaml_tag_directive_t* }
        { top yaml_tag_directive_t* }
    ;

    ! /** Anchor analysis. */
    STRUCT: yaml_emitter_anchor_data
        { anchor c-string }
        { anchor_length size_t }
        { alias int }
    ;

    ! /** Tag analysis. */
    STRUCT: yaml_emitter_tag_data
        { handle c-string }
        { handle_length size_t }
        { suffix c-string }
        { suffix_length size_t }
    ;

    ! /** Scalar analysis. */
    STRUCT: yaml_emitter_scalar_data
        { value c-string }
        { length size_t }
        { multiline int }
        { flow_plain_allowed int }
        { block_plain_allowed int }
        { single_quoted_allowed int }
        { block_allowed int }
        { style yaml_scalar_style_t }
    ;

    ! /** The information associated with the document nodes. */
    STRUCT: yaml_emitter_anchors
        { references int }
        { anchor int }
        { serialized int }
    ;
STRUCT: yaml_emitter_t

    { error yaml_error_type_t }
    { problem c-string }

    { write_handler yaml_write_handler_t* }

    { write_handler_data void* }

    { output yaml_emitter_output }

    { buffer yaml_emitter_buffer }

    { raw_buffer yaml_emitter_raw_buffer }

    { encoding yaml_encoding_t }

    { canonical int }
    { best_indent int }
    { best_width int }
    { unicode int }
    { line_break yaml_break_t }

    { states yaml_emitter_states }
    { state yaml_emitter_state_t }

    { events yaml_emitter_events }

    { indents yaml_emitter_indents }

    { tag_directives yaml_emitter_tag_directives }

    { indent int }

    { flow_level int }

    { root_context int }
    { sequence_context int }
    { mapping_context int }
    { simple_key_context int }

    { line int }
    { column int }
    { whitespace int }
    { indention int }
    { open_ended int }

    { anchor_data yaml_emitter_anchor_data }

    { tag_data yaml_emitter_tag_data }

    { scalar_data yaml_emitter_scalar_data }

    { opened int }
    { closed int }

    { anchors yaml_emitter_anchors* }

    { last_anchor_id int }

    { document yaml_document_t* }

;

! /**
!  * Initialize an emitter.
!  *
!  * This function creates a new emitter object.  An application is responsible
!  * for destroying the object using the yaml_emitter_delete() function.
!  *
!  * @param[out]      emitter     An empty parser object.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_emitter_initialize ( yaml_emitter_t *emitter )

! /**
!  * Destroy an emitter.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  */

FUNCTION: void
yaml_emitter_delete ( yaml_emitter_t *emitter )
DESTRUCTOR: yaml_emitter_delete

! /**
!  * Set a string output.
!  *
!  * The emitter will write the output characters to the @a output buffer of the
!  * size @a size.  The emitter will set @a size_written to the number of written
!  * bytes.  If the buffer is smaller than required, the emitter produces the
!  * YAML_WRITE_ERROR error.
!  *
!  * @param[in,out]   emitter         An emitter object.
!  * @param[in]       output          An output buffer.
!  * @param[in]       size            The buffer size.
!  * @param[in]       size_written    The pointer to save the number of written
!  *                                  bytes.
!  */

FUNCTION: void
yaml_emitter_set_output_string ( yaml_emitter_t *emitter,
        uchar *output, size_t size, size_t *size_written )

! /**
!  * Set a file output.
!  *
!  * @a file should be a file object open for writing.  The application is
!  * responsible for closing the @a file.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  * @param[in]       file        An open file.
!  */

FUNCTION: void
yaml_emitter_set_output_file ( yaml_emitter_t *emitter, FILE *file )

! /**
!  * Set a generic output handler.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  * @param[in]       handler     A write handler.
!  * @param[in]       data        Any application data for passing to the write
!  *                              handler.
!  */

FUNCTION: void
yaml_emitter_set_output ( yaml_emitter_t *emitter,
        yaml_write_handler_t *handler, void *data )

! /**
!  * Set the output encoding.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  * @param[in]       encoding    The output encoding.
!  */

FUNCTION: void
yaml_emitter_set_encoding ( yaml_emitter_t *emitter, yaml_encoding_t encoding )

! /**
!  * Set if the output should be in the "canonical" format as in the YAML
!  * specification.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  * @param[in]       canonical   If the output is canonical.
!  */

FUNCTION: void
yaml_emitter_set_canonical ( yaml_emitter_t *emitter, bool canonical )

! /**
!  * Set the intendation increment.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  * @param[in]       indent      The indentation increment (1 < . < 10).
!  */

FUNCTION: void
yaml_emitter_set_indent ( yaml_emitter_t *emitter, int indent )

! /**
!  * Set the preferred line width. @c -1 means unlimited.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  * @param[in]       width       The preferred line width.
!  */

FUNCTION: void
yaml_emitter_set_width ( yaml_emitter_t *emitter, int width )

! /**
!  * Set if unescaped non-ASCII characters are allowed.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  * @param[in]       unicode     If unescaped Unicode characters are allowed.
!  */

FUNCTION: void
yaml_emitter_set_unicode ( yaml_emitter_t *emitter, bool unicode )

! /**
!  * Set the preferred line break.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  * @param[in]       line_break  The preferred line break.
!  */

FUNCTION: void
yaml_emitter_set_break ( yaml_emitter_t *emitter, yaml_break_t line_break )

! /**
!  * Emit an event.
!  *
!  * The event object may be generated using the yaml_parser_parse() function.
!  * The emitter takes the responsibility for the event object and destroys its
!  * content after it is emitted. The event object is destroyed even if the
!  * function fails.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  * @param[in,out]   event       An event object.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_emitter_emit ( yaml_emitter_t *emitter, yaml_event_t *event )

! /**
!  * Start a YAML stream.
!  *
!  * This function should be used before yaml_emitter_dump() is called.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_emitter_open ( yaml_emitter_t *emitter )

! /**
!  * Finish a YAML stream.
!  *
!  * This function should be used after yaml_emitter_dump() is called.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_emitter_close ( yaml_emitter_t *emitter )

! /**
!  * Emit a YAML document.
!  *
!  * The documen object may be generated using the yaml_parser_load() function
!  * or the yaml_document_initialize() function.  The emitter takes the
!  * responsibility for the document object and destoys its content after
!  * it is emitted. The document object is destroyedeven if the function fails.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  * @param[in,out]   document    A document object.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_emitter_dump ( yaml_emitter_t *emitter, yaml_document_t *document )

! /**
!  * Flush the accumulated characters to the output.
!  *
!  * @param[in,out]   emitter     An emitter object.
!  *
!  * @returns @c 1 if the function succeeded, @c 0 on error.
!  */

FUNCTION: bool
yaml_emitter_flush ( yaml_emitter_t *emitter )

! /** @} */

! #ifdef __cplusplus
! }
! #endif

! #endif /* #ifndef YAML_H */
