USING: accessors continuations gobject-introspection.common
gobject-introspection.loader kernel locals namespaces sequences tools.test
xml ;
IN: gobject-introspection.loader.tests

:: skipped-methods ( names -- identifiers )
    skip-definitions get-global :> previous
    [
        names skip-definitions set-global
        "<class xmlns:c='http://www.gtk.org/introspection/c/1.0'>
          <method name='keep' c:identifier='test_keep'>
            <return-value><type name='none'/></return-value>
          </method>
          <method name='override' c:identifier='test_override'>
            <return-value><type name='none'/></return-value>
          </method>
        </class>" string>xml
        "method" load-functions [ identifier>> ] map
    ] [ previous skip-definitions set-global ] finally ;

{ { "test_keep" "test_override" } } [ { } skipped-methods ] unit-test
{ { "test_keep" } } [ { "test_override" } skipped-methods ] unit-test

! Match the C identifier, not a short method name shared by unrelated types.
{ { "test_keep" "test_override" } } [ { "override" } skipped-methods ] unit-test

{ t } [
    "<parameter name='allocation' direction='out' caller-allocates='1'>
       <type name='Allocation'/>
     </parameter>" string>xml xml>parameter caller-allocates?>>
] unit-test

{ f } [
    "<parameter name='error' direction='out'>
       <type name='GLib.Error'/>
     </parameter>" string>xml xml>parameter caller-allocates?>>
] unit-test
