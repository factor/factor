! Copyright (C) 2010 Erik Charlebois.
! See http://factorcode.org/license.txt for BSD license.
USING: ;
IN: dwarf

CONSTANT: DW_TAG_array_type               HEX: 01
CONSTANT: DW_TAG_class_type               HEX: 02
CONSTANT: DW_TAG_entry_point              HEX: 03
CONSTANT: DW_TAG_enumeration_type         HEX: 04
CONSTANT: DW_TAG_formal_parameter         HEX: 05
CONSTANT: DW_TAG_imported_declaration     HEX: 08
CONSTANT: DW_TAG_label                    HEX: 0a
CONSTANT: DW_TAG_lexical_block            HEX: 0b
CONSTANT: DW_TAG_member                   HEX: 0d
CONSTANT: DW_TAG_pointer_type             HEX: 0f
CONSTANT: DW_TAG_reference_type           HEX: 10
CONSTANT: DW_TAG_compile_unit             HEX: 11
CONSTANT: DW_TAG_string_type              HEX: 12
CONSTANT: DW_TAG_structure_type           HEX: 13
CONSTANT: DW_TAG_subroutine_type          HEX: 15
CONSTANT: DW_TAG_typedef                  HEX: 16
CONSTANT: DW_TAG_union_type               HEX: 17
CONSTANT: DW_TAG_unspecified_parameters   HEX: 18
CONSTANT: DW_TAG_variant                  HEX: 19
CONSTANT: DW_TAG_common_block             HEX: 1a
CONSTANT: DW_TAG_common_inclusion         HEX: 1b
CONSTANT: DW_TAG_inheritance              HEX: 1c
CONSTANT: DW_TAG_inlined_subroutine       HEX: 1d
CONSTANT: DW_TAG_module                   HEX: 1e
CONSTANT: DW_TAG_ptr_to_member_type       HEX: 1f
CONSTANT: DW_TAG_set_type                 HEX: 20
CONSTANT: DW_TAG_subrange_type            HEX: 21
CONSTANT: DW_TAG_with_stmt                HEX: 22
CONSTANT: DW_TAG_access_declaration       HEX: 23
CONSTANT: DW_TAG_base_type                HEX: 24
CONSTANT: DW_TAG_catch_block              HEX: 25
CONSTANT: DW_TAG_const_type               HEX: 26
CONSTANT: DW_TAG_constant                 HEX: 27
CONSTANT: DW_TAG_enumerator               HEX: 28
CONSTANT: DW_TAG_file_type                HEX: 29
CONSTANT: DW_TAG_friend                   HEX: 2a
CONSTANT: DW_TAG_namelist                 HEX: 2b
CONSTANT: DW_TAG_namelist_item            HEX: 2c
CONSTANT: DW_TAG_packed_type              HEX: 2d
CONSTANT: DW_TAG_subprogram               HEX: 2e
CONSTANT: DW_TAG_template_type_parameter  HEX: 2f
CONSTANT: DW_TAG_template_value_parameter HEX: 30
CONSTANT: DW_TAG_thrown_type              HEX: 31
CONSTANT: DW_TAG_try_block                HEX: 32
CONSTANT: DW_TAG_variant_part             HEX: 33
CONSTANT: DW_TAG_variable                 HEX: 34
CONSTANT: DW_TAG_volatile_type            HEX: 35
CONSTANT: DW_TAG_dwarf_procedure          HEX: 36
CONSTANT: DW_TAG_restrict_type            HEX: 37
CONSTANT: DW_TAG_interface_type           HEX: 38
CONSTANT: DW_TAG_namespace                HEX: 39
CONSTANT: DW_TAG_imported_module          HEX: 3a
CONSTANT: DW_TAG_unspecified_type         HEX: 3b
CONSTANT: DW_TAG_partial_unit             HEX: 3c
CONSTANT: DW_TAG_imported_unit            HEX: 3d
CONSTANT: DW_TAG_condition                HEX: 3f
CONSTANT: DW_TAG_shared_type              HEX: 40
CONSTANT: DW_TAG_type_unit                HEX: 41
CONSTANT: DW_TAG_rvalue_reference_type    HEX: 42
CONSTANT: DW_TAG_template_alias           HEX: 43

CONSTANT: DW_TAG_lo_user                  HEX: 4080

CONSTANT: DW_TAG_MIPS_loop                HEX: 4081
CONSTANT: DW_TAG_HP_array_descriptor      HEX: 4090
CONSTANT: DW_TAG_format_label             HEX: 4101
CONSTANT: DW_TAG_function_template        HEX: 4102
CONSTANT: DW_TAG_class_template           HEX: 4103
CONSTANT: DW_TAG_GNU_BINCL                HEX: 4104
CONSTANT: DW_TAG_GNU_EINCL                HEX: 4105
CONSTANT: DW_TAG_GNU_template_template_parameter  HEX: 4106
CONSTANT: DW_TAG_GNU_template_parameter_pack      HEX: 4107
CONSTANT: DW_TAG_GNU_formal_parameter_pack        HEX: 4108
CONSTANT: DW_TAG_ALTIUM_circ_type         HEX: 5101
CONSTANT: DW_TAG_ALTIUM_mwa_circ_type     HEX: 5102
CONSTANT: DW_TAG_ALTIUM_rev_carry_type    HEX: 5103
CONSTANT: DW_TAG_ALTIUM_rom               HEX: 5111
CONSTANT: DW_TAG_upc_shared_type          HEX: 8765
CONSTANT: DW_TAG_upc_strict_type          HEX: 8766
CONSTANT: DW_TAG_upc_relaxed_type         HEX: 8767
CONSTANT: DW_TAG_PGI_kanji_type           HEX: a000
CONSTANT: DW_TAG_PGI_interface_block      HEX: a020
CONSTANT: DW_TAG_SUN_function_template    HEX: 4201
CONSTANT: DW_TAG_SUN_class_template       HEX: 4202
CONSTANT: DW_TAG_SUN_struct_template      HEX: 4203
CONSTANT: DW_TAG_SUN_union_template       HEX: 4204
CONSTANT: DW_TAG_SUN_indirect_inheritance HEX: 4205
CONSTANT: DW_TAG_SUN_codeflags            HEX: 4206
CONSTANT: DW_TAG_SUN_memop_info           HEX: 4207
CONSTANT: DW_TAG_SUN_omp_child_func       HEX: 4208
CONSTANT: DW_TAG_SUN_rtti_descriptor      HEX: 4209
CONSTANT: DW_TAG_SUN_dtor_info            HEX: 420a
CONSTANT: DW_TAG_SUN_dtor                 HEX: 420b
CONSTANT: DW_TAG_SUN_f90_interface        HEX: 420c
CONSTANT: DW_TAG_SUN_fortran_vax_structure HEX: 420d
CONSTANT: DW_TAG_SUN_hi                   HEX: 42ff
    
CONSTANT: DW_TAG_hi_user                  HEX: ffff

CONSTANT: DW_children_no  0
CONSTANT: DW_children_yes 1

CONSTANT: DW_FORM_addr                    HEX: 01
CONSTANT: DW_FORM_block2                  HEX: 03
CONSTANT: DW_FORM_block4                  HEX: 04
CONSTANT: DW_FORM_data2                   HEX: 05
CONSTANT: DW_FORM_data4                   HEX: 06
CONSTANT: DW_FORM_data8                   HEX: 07
CONSTANT: DW_FORM_string                  HEX: 08
CONSTANT: DW_FORM_block                   HEX: 09
CONSTANT: DW_FORM_block1                  HEX: 0a
CONSTANT: DW_FORM_data1                   HEX: 0b
CONSTANT: DW_FORM_flag                    HEX: 0c
CONSTANT: DW_FORM_sdata                   HEX: 0d
CONSTANT: DW_FORM_strp                    HEX: 0e
CONSTANT: DW_FORM_udata                   HEX: 0f
CONSTANT: DW_FORM_ref_addr                HEX: 10
CONSTANT: DW_FORM_ref1                    HEX: 11
CONSTANT: DW_FORM_ref2                    HEX: 12
CONSTANT: DW_FORM_ref4                    HEX: 13
CONSTANT: DW_FORM_ref8                    HEX: 14
CONSTANT: DW_FORM_ref_udata               HEX: 15
CONSTANT: DW_FORM_indirect                HEX: 16
CONSTANT: DW_FORM_sec_offset              HEX: 17
CONSTANT: DW_FORM_exprloc                 HEX: 18
CONSTANT: DW_FORM_flag_present            HEX: 19
CONSTANT: DW_FORM_ref_sig8                HEX: 20

CONSTANT: DW_AT_sibling                           HEX: 01
CONSTANT: DW_AT_location                          HEX: 02
CONSTANT: DW_AT_name                              HEX: 03
CONSTANT: DW_AT_ordering                          HEX: 09
CONSTANT: DW_AT_subscr_data                       HEX: 0a
CONSTANT: DW_AT_byte_size                         HEX: 0b
CONSTANT: DW_AT_bit_offset                        HEX: 0c
CONSTANT: DW_AT_bit_size                          HEX: 0d
CONSTANT: DW_AT_element_list                      HEX: 0f
CONSTANT: DW_AT_stmt_list                         HEX: 10
CONSTANT: DW_AT_low_pc                            HEX: 11
CONSTANT: DW_AT_high_pc                           HEX: 12
CONSTANT: DW_AT_language                          HEX: 13
CONSTANT: DW_AT_member                            HEX: 14
CONSTANT: DW_AT_discr                             HEX: 15
CONSTANT: DW_AT_discr_value                       HEX: 16
CONSTANT: DW_AT_visibility                        HEX: 17
CONSTANT: DW_AT_import                            HEX: 18
CONSTANT: DW_AT_string_length                     HEX: 19
CONSTANT: DW_AT_common_reference                  HEX: 1a
CONSTANT: DW_AT_comp_dir                          HEX: 1b
CONSTANT: DW_AT_const_value                       HEX: 1c
CONSTANT: DW_AT_containing_type                   HEX: 1d
CONSTANT: DW_AT_default_value                     HEX: 1e
CONSTANT: DW_AT_inline                            HEX: 20
CONSTANT: DW_AT_is_optional                       HEX: 21
CONSTANT: DW_AT_lower_bound                       HEX: 22
CONSTANT: DW_AT_producer                          HEX: 25
CONSTANT: DW_AT_prototyped                        HEX: 27
CONSTANT: DW_AT_return_addr                       HEX: 2a
CONSTANT: DW_AT_start_scope                       HEX: 2c
CONSTANT: DW_AT_bit_stride                        HEX: 2e
CONSTANT: DW_AT_upper_bound                       HEX: 2f
CONSTANT: DW_AT_abstract_origin                   HEX: 31
CONSTANT: DW_AT_accessibility                     HEX: 32
CONSTANT: DW_AT_address_class                     HEX: 33
CONSTANT: DW_AT_artificial                        HEX: 34
CONSTANT: DW_AT_base_types                        HEX: 35
CONSTANT: DW_AT_calling_convention                HEX: 36
CONSTANT: DW_AT_count                             HEX: 37
CONSTANT: DW_AT_data_member_location              HEX: 38
CONSTANT: DW_AT_decl_column                       HEX: 39
CONSTANT: DW_AT_decl_file                         HEX: 3a
CONSTANT: DW_AT_decl_line                         HEX: 3b
CONSTANT: DW_AT_declaration                       HEX: 3c
CONSTANT: DW_AT_discr_list                        HEX: 3d
CONSTANT: DW_AT_encoding                          HEX: 3e
CONSTANT: DW_AT_external                          HEX: 3f
CONSTANT: DW_AT_frame_base                        HEX: 40
CONSTANT: DW_AT_friend                            HEX: 41
CONSTANT: DW_AT_identifier_case                   HEX: 42
CONSTANT: DW_AT_macro_info                        HEX: 43
CONSTANT: DW_AT_namelist_item                     HEX: 44
CONSTANT: DW_AT_priority                          HEX: 45
CONSTANT: DW_AT_segment                           HEX: 46
CONSTANT: DW_AT_specification                     HEX: 47
CONSTANT: DW_AT_static_link                       HEX: 48
CONSTANT: DW_AT_type                              HEX: 49
CONSTANT: DW_AT_use_location                      HEX: 4a
CONSTANT: DW_AT_variable_parameter                HEX: 4b
CONSTANT: DW_AT_virtuality                        HEX: 4c
CONSTANT: DW_AT_vtable_elem_location              HEX: 4d
CONSTANT: DW_AT_allocated                         HEX: 4e
CONSTANT: DW_AT_associated                        HEX: 4f
CONSTANT: DW_AT_data_location                     HEX: 50
CONSTANT: DW_AT_byte_stride                       HEX: 51
CONSTANT: DW_AT_entry_pc                          HEX: 52
CONSTANT: DW_AT_use_UTF8                          HEX: 53
CONSTANT: DW_AT_extension                         HEX: 54
CONSTANT: DW_AT_ranges                            HEX: 55
CONSTANT: DW_AT_trampoline                        HEX: 56
CONSTANT: DW_AT_call_column                       HEX: 57
CONSTANT: DW_AT_call_file                         HEX: 58
CONSTANT: DW_AT_call_line                         HEX: 59
CONSTANT: DW_AT_description                       HEX: 5a
CONSTANT: DW_AT_binary_scale                      HEX: 5b
CONSTANT: DW_AT_decimal_scale                     HEX: 5c
CONSTANT: DW_AT_small                             HEX: 5d
CONSTANT: DW_AT_decimal_sign                      HEX: 5e
CONSTANT: DW_AT_digit_count                       HEX: 5f
CONSTANT: DW_AT_picture_string                    HEX: 60
CONSTANT: DW_AT_mutable                           HEX: 61
CONSTANT: DW_AT_threads_scaled                    HEX: 62
CONSTANT: DW_AT_explicit                          HEX: 63
CONSTANT: DW_AT_object_pointer                    HEX: 64
CONSTANT: DW_AT_endianity                         HEX: 65
CONSTANT: DW_AT_elemental                         HEX: 66
CONSTANT: DW_AT_pure                              HEX: 67
CONSTANT: DW_AT_recursive                         HEX: 68
CONSTANT: DW_AT_signature                         HEX: 69
CONSTANT: DW_AT_main_subprogram                   HEX: 6a
CONSTANT: DW_AT_data_bit_offset                   HEX: 6b
CONSTANT: DW_AT_const_expr                        HEX: 6c
CONSTANT: DW_AT_enum_class                        HEX: 6d
CONSTANT: DW_AT_linkage_name                      HEX: 6e

CONSTANT: DW_AT_HP_block_index                    HEX: 2000

CONSTANT: DW_AT_lo_user                           HEX: 2000

CONSTANT: DW_AT_MIPS_fde                          HEX: 2001
CONSTANT: DW_AT_MIPS_loop_begin                   HEX: 2002
CONSTANT: DW_AT_MIPS_tail_loop_begin              HEX: 2003
CONSTANT: DW_AT_MIPS_epilog_begin                 HEX: 2004
CONSTANT: DW_AT_MIPS_loop_unroll_factor           HEX: 2005
CONSTANT: DW_AT_MIPS_software_pipeline_depth      HEX: 2006
CONSTANT: DW_AT_MIPS_linkage_name                 HEX: 2007
CONSTANT: DW_AT_MIPS_stride                       HEX: 2008
CONSTANT: DW_AT_MIPS_abstract_name                HEX: 2009
CONSTANT: DW_AT_MIPS_clone_origin                 HEX: 200a
CONSTANT: DW_AT_MIPS_has_inlines                  HEX: 200b
CONSTANT: DW_AT_MIPS_stride_byte                  HEX: 200c
CONSTANT: DW_AT_MIPS_stride_elem                  HEX: 200d
CONSTANT: DW_AT_MIPS_ptr_dopetype                 HEX: 200e
CONSTANT: DW_AT_MIPS_allocatable_dopetype         HEX: 200f
CONSTANT: DW_AT_MIPS_assumed_shape_dopetype       HEX: 2010
CONSTANT: DW_AT_MIPS_assumed_size                 HEX: 2011

CONSTANT: DW_AT_HP_unmodifiable                   HEX: 2001
CONSTANT: DW_AT_HP_actuals_stmt_list              HEX: 2010
CONSTANT: DW_AT_HP_proc_per_section               HEX: 2011
CONSTANT: DW_AT_HP_raw_data_ptr                   HEX: 2012
CONSTANT: DW_AT_HP_pass_by_reference              HEX: 2013
CONSTANT: DW_AT_HP_opt_level                      HEX: 2014
CONSTANT: DW_AT_HP_prof_version_id                HEX: 2015
CONSTANT: DW_AT_HP_opt_flags                      HEX: 2016
CONSTANT: DW_AT_HP_cold_region_low_pc             HEX: 2017
CONSTANT: DW_AT_HP_cold_region_high_pc            HEX: 2018
CONSTANT: DW_AT_HP_all_variables_modifiable       HEX: 2019
CONSTANT: DW_AT_HP_linkage_name                   HEX: 201a
CONSTANT: DW_AT_HP_prof_flags                     HEX: 201b

CONSTANT: DW_AT_CPQ_discontig_ranges              HEX: 2001
CONSTANT: DW_AT_CPQ_semantic_events               HEX: 2002
CONSTANT: DW_AT_CPQ_split_lifetimes_var           HEX: 2003
CONSTANT: DW_AT_CPQ_split_lifetimes_rtn           HEX: 2004
CONSTANT: DW_AT_CPQ_prologue_length               HEX: 2005

CONSTANT: DW_AT_INTEL_other_endian                HEX: 2026

CONSTANT: DW_AT_sf_names                          HEX: 2101
CONSTANT: DW_AT_src_info                          HEX: 2102
CONSTANT: DW_AT_mac_info                          HEX: 2103
CONSTANT: DW_AT_src_coords                        HEX: 2104
CONSTANT: DW_AT_body_begin                        HEX: 2105
CONSTANT: DW_AT_body_end                          HEX: 2106
CONSTANT: DW_AT_GNU_vector                        HEX: 2107
CONSTANT: DW_AT_GNU_template_name                 HEX: 2108

CONSTANT: DW_AT_ALTIUM_loclist    HEX: 2300         

CONSTANT: DW_AT_SUN_template                      HEX: 2201
CONSTANT: DW_AT_VMS_rtnbeg_pd_address             HEX: 2201
CONSTANT: DW_AT_SUN_alignment                     HEX: 2202
CONSTANT: DW_AT_SUN_vtable                        HEX: 2203
CONSTANT: DW_AT_SUN_count_guarantee               HEX: 2204
CONSTANT: DW_AT_SUN_command_line                  HEX: 2205
CONSTANT: DW_AT_SUN_vbase                         HEX: 2206
CONSTANT: DW_AT_SUN_compile_options               HEX: 2207
CONSTANT: DW_AT_SUN_language                      HEX: 2208
CONSTANT: DW_AT_SUN_browser_file                  HEX: 2209
CONSTANT: DW_AT_SUN_vtable_abi                    HEX: 2210
CONSTANT: DW_AT_SUN_func_offsets                  HEX: 2211
CONSTANT: DW_AT_SUN_cf_kind                       HEX: 2212
CONSTANT: DW_AT_SUN_vtable_index                  HEX: 2213
CONSTANT: DW_AT_SUN_omp_tpriv_addr                HEX: 2214
CONSTANT: DW_AT_SUN_omp_child_func                HEX: 2215
CONSTANT: DW_AT_SUN_func_offset                   HEX: 2216
CONSTANT: DW_AT_SUN_memop_type_ref                HEX: 2217
CONSTANT: DW_AT_SUN_profile_id                    HEX: 2218
CONSTANT: DW_AT_SUN_memop_signature               HEX: 2219
CONSTANT: DW_AT_SUN_obj_dir                       HEX: 2220
CONSTANT: DW_AT_SUN_obj_file                      HEX: 2221
CONSTANT: DW_AT_SUN_original_name                 HEX: 2222
CONSTANT: DW_AT_SUN_hwcprof_signature             HEX: 2223
CONSTANT: DW_AT_SUN_amd64_parmdump                HEX: 2224
CONSTANT: DW_AT_SUN_part_link_name                HEX: 2225
CONSTANT: DW_AT_SUN_link_name                     HEX: 2226
CONSTANT: DW_AT_SUN_pass_with_const               HEX: 2227
CONSTANT: DW_AT_SUN_return_with_const             HEX: 2228
CONSTANT: DW_AT_SUN_import_by_name                HEX: 2229
CONSTANT: DW_AT_SUN_f90_pointer                   HEX: 222a
CONSTANT: DW_AT_SUN_pass_by_ref                   HEX: 222b
CONSTANT: DW_AT_SUN_f90_allocatable               HEX: 222c
CONSTANT: DW_AT_SUN_f90_assumed_shape_array       HEX: 222d
CONSTANT: DW_AT_SUN_c_vla                         HEX: 222e
CONSTANT: DW_AT_SUN_return_value_ptr              HEX: 2230
CONSTANT: DW_AT_SUN_dtor_start                    HEX: 2231
CONSTANT: DW_AT_SUN_dtor_length                   HEX: 2232
CONSTANT: DW_AT_SUN_dtor_state_initial            HEX: 2233
CONSTANT: DW_AT_SUN_dtor_state_final              HEX: 2234
CONSTANT: DW_AT_SUN_dtor_state_deltas             HEX: 2235
CONSTANT: DW_AT_SUN_import_by_lname               HEX: 2236
CONSTANT: DW_AT_SUN_f90_use_only                  HEX: 2237
CONSTANT: DW_AT_SUN_namelist_spec                 HEX: 2238
CONSTANT: DW_AT_SUN_is_omp_child_func             HEX: 2239
CONSTANT: DW_AT_SUN_fortran_main_alias            HEX: 223a
CONSTANT: DW_AT_SUN_fortran_based                 HEX: 223b

CONSTANT: DW_AT_upc_threads_scaled                HEX: 3210

CONSTANT: DW_AT_PGI_lbase                         HEX: 3a00
CONSTANT: DW_AT_PGI_soffset                       HEX: 3a01 
CONSTANT: DW_AT_PGI_lstride                       HEX: 3a02 

CONSTANT: DW_AT_APPLE_closure                     HEX: 3fe4
CONSTANT: DW_AT_APPLE_major_runtime_vers          HEX: 3fe5
CONSTANT: DW_AT_APPLE_runtime_class               HEX: 3fe6

CONSTANT: DW_AT_hi_user                           HEX: 3fff

CONSTANT: DW_OP_addr                      HEX: 03
CONSTANT: DW_OP_deref                     HEX: 06
CONSTANT: DW_OP_const1u                   HEX: 08
CONSTANT: DW_OP_const1s                   HEX: 09
CONSTANT: DW_OP_const2u                   HEX: 0a
CONSTANT: DW_OP_const2s                   HEX: 0b
CONSTANT: DW_OP_const4u                   HEX: 0c
CONSTANT: DW_OP_const4s                   HEX: 0d
CONSTANT: DW_OP_const8u                   HEX: 0e
CONSTANT: DW_OP_const8s                   HEX: 0f
CONSTANT: DW_OP_constu                    HEX: 10
CONSTANT: DW_OP_consts                    HEX: 11
CONSTANT: DW_OP_dup                       HEX: 12
CONSTANT: DW_OP_drop                      HEX: 13
CONSTANT: DW_OP_over                      HEX: 14
CONSTANT: DW_OP_pick                      HEX: 15
CONSTANT: DW_OP_swap                      HEX: 16
CONSTANT: DW_OP_rot                       HEX: 17
CONSTANT: DW_OP_xderef                    HEX: 18
CONSTANT: DW_OP_abs                       HEX: 19
CONSTANT: DW_OP_and                       HEX: 1a
CONSTANT: DW_OP_div                       HEX: 1b
CONSTANT: DW_OP_minus                     HEX: 1c
CONSTANT: DW_OP_mod                       HEX: 1d
CONSTANT: DW_OP_mul                       HEX: 1e
CONSTANT: DW_OP_neg                       HEX: 1f
CONSTANT: DW_OP_not                       HEX: 20
CONSTANT: DW_OP_or                        HEX: 21
CONSTANT: DW_OP_plus                      HEX: 22
CONSTANT: DW_OP_plus_uconst               HEX: 23
CONSTANT: DW_OP_shl                       HEX: 24
CONSTANT: DW_OP_shr                       HEX: 25
CONSTANT: DW_OP_shra                      HEX: 26
CONSTANT: DW_OP_xor                       HEX: 27
CONSTANT: DW_OP_bra                       HEX: 28
CONSTANT: DW_OP_eq                        HEX: 29
CONSTANT: DW_OP_ge                        HEX: 2a
CONSTANT: DW_OP_gt                        HEX: 2b
CONSTANT: DW_OP_le                        HEX: 2c
CONSTANT: DW_OP_lt                        HEX: 2d
CONSTANT: DW_OP_ne                        HEX: 2e
CONSTANT: DW_OP_skip                      HEX: 2f
CONSTANT: DW_OP_lit0                      HEX: 30
CONSTANT: DW_OP_lit1                      HEX: 31
CONSTANT: DW_OP_lit2                      HEX: 32
CONSTANT: DW_OP_lit3                      HEX: 33
CONSTANT: DW_OP_lit4                      HEX: 34
CONSTANT: DW_OP_lit5                      HEX: 35
CONSTANT: DW_OP_lit6                      HEX: 36
CONSTANT: DW_OP_lit7                      HEX: 37
CONSTANT: DW_OP_lit8                      HEX: 38
CONSTANT: DW_OP_lit9                      HEX: 39
CONSTANT: DW_OP_lit10                     HEX: 3a
CONSTANT: DW_OP_lit11                     HEX: 3b
CONSTANT: DW_OP_lit12                     HEX: 3c
CONSTANT: DW_OP_lit13                     HEX: 3d
CONSTANT: DW_OP_lit14                     HEX: 3e
CONSTANT: DW_OP_lit15                     HEX: 3f
CONSTANT: DW_OP_lit16                     HEX: 40
CONSTANT: DW_OP_lit17                     HEX: 41
CONSTANT: DW_OP_lit18                     HEX: 42
CONSTANT: DW_OP_lit19                     HEX: 43
CONSTANT: DW_OP_lit20                     HEX: 44
CONSTANT: DW_OP_lit21                     HEX: 45
CONSTANT: DW_OP_lit22                     HEX: 46
CONSTANT: DW_OP_lit23                     HEX: 47
CONSTANT: DW_OP_lit24                     HEX: 48
CONSTANT: DW_OP_lit25                     HEX: 49
CONSTANT: DW_OP_lit26                     HEX: 4a
CONSTANT: DW_OP_lit27                     HEX: 4b
CONSTANT: DW_OP_lit28                     HEX: 4c
CONSTANT: DW_OP_lit29                     HEX: 4d
CONSTANT: DW_OP_lit30                     HEX: 4e
CONSTANT: DW_OP_lit31                     HEX: 4f
CONSTANT: DW_OP_reg0                      HEX: 50
CONSTANT: DW_OP_reg1                      HEX: 51
CONSTANT: DW_OP_reg2                      HEX: 52
CONSTANT: DW_OP_reg3                      HEX: 53
CONSTANT: DW_OP_reg4                      HEX: 54
CONSTANT: DW_OP_reg5                      HEX: 55
CONSTANT: DW_OP_reg6                      HEX: 56
CONSTANT: DW_OP_reg7                      HEX: 57
CONSTANT: DW_OP_reg8                      HEX: 58
CONSTANT: DW_OP_reg9                      HEX: 59
CONSTANT: DW_OP_reg10                     HEX: 5a
CONSTANT: DW_OP_reg11                     HEX: 5b
CONSTANT: DW_OP_reg12                     HEX: 5c
CONSTANT: DW_OP_reg13                     HEX: 5d
CONSTANT: DW_OP_reg14                     HEX: 5e
CONSTANT: DW_OP_reg15                     HEX: 5f
CONSTANT: DW_OP_reg16                     HEX: 60
CONSTANT: DW_OP_reg17                     HEX: 61
CONSTANT: DW_OP_reg18                     HEX: 62
CONSTANT: DW_OP_reg19                     HEX: 63
CONSTANT: DW_OP_reg20                     HEX: 64
CONSTANT: DW_OP_reg21                     HEX: 65
CONSTANT: DW_OP_reg22                     HEX: 66
CONSTANT: DW_OP_reg23                     HEX: 67
CONSTANT: DW_OP_reg24                     HEX: 68
CONSTANT: DW_OP_reg25                     HEX: 69
CONSTANT: DW_OP_reg26                     HEX: 6a
CONSTANT: DW_OP_reg27                     HEX: 6b
CONSTANT: DW_OP_reg28                     HEX: 6c
CONSTANT: DW_OP_reg29                     HEX: 6d
CONSTANT: DW_OP_reg30                     HEX: 6e
CONSTANT: DW_OP_reg31                     HEX: 6f
CONSTANT: DW_OP_breg0                     HEX: 70
CONSTANT: DW_OP_breg1                     HEX: 71
CONSTANT: DW_OP_breg2                     HEX: 72
CONSTANT: DW_OP_breg3                     HEX: 73
CONSTANT: DW_OP_breg4                     HEX: 74
CONSTANT: DW_OP_breg5                     HEX: 75
CONSTANT: DW_OP_breg6                     HEX: 76
CONSTANT: DW_OP_breg7                     HEX: 77
CONSTANT: DW_OP_breg8                     HEX: 78
CONSTANT: DW_OP_breg9                     HEX: 79
CONSTANT: DW_OP_breg10                    HEX: 7a
CONSTANT: DW_OP_breg11                    HEX: 7b
CONSTANT: DW_OP_breg12                    HEX: 7c
CONSTANT: DW_OP_breg13                    HEX: 7d
CONSTANT: DW_OP_breg14                    HEX: 7e
CONSTANT: DW_OP_breg15                    HEX: 7f
CONSTANT: DW_OP_breg16                    HEX: 80
CONSTANT: DW_OP_breg17                    HEX: 81
CONSTANT: DW_OP_breg18                    HEX: 82
CONSTANT: DW_OP_breg19                    HEX: 83
CONSTANT: DW_OP_breg20                    HEX: 84
CONSTANT: DW_OP_breg21                    HEX: 85
CONSTANT: DW_OP_breg22                    HEX: 86
CONSTANT: DW_OP_breg23                    HEX: 87
CONSTANT: DW_OP_breg24                    HEX: 88
CONSTANT: DW_OP_breg25                    HEX: 89
CONSTANT: DW_OP_breg26                    HEX: 8a
CONSTANT: DW_OP_breg27                    HEX: 8b
CONSTANT: DW_OP_breg28                    HEX: 8c
CONSTANT: DW_OP_breg29                    HEX: 8d
CONSTANT: DW_OP_breg30                    HEX: 8e
CONSTANT: DW_OP_breg31                    HEX: 8f
CONSTANT: DW_OP_regx                      HEX: 90
CONSTANT: DW_OP_fbreg                     HEX: 91
CONSTANT: DW_OP_bregx                     HEX: 92
CONSTANT: DW_OP_piece                     HEX: 93
CONSTANT: DW_OP_deref_size                HEX: 94
CONSTANT: DW_OP_xderef_size               HEX: 95
CONSTANT: DW_OP_nop                       HEX: 96
CONSTANT: DW_OP_push_object_address       HEX: 97
CONSTANT: DW_OP_call2                     HEX: 98
CONSTANT: DW_OP_call4                     HEX: 99
CONSTANT: DW_OP_call_ref                  HEX: 9a
CONSTANT: DW_OP_form_tls_address          HEX: 9b
CONSTANT: DW_OP_call_frame_cfa            HEX: 9c
CONSTANT: DW_OP_bit_piece                 HEX: 9d
CONSTANT: DW_OP_implicit_value            HEX: 9e
CONSTANT: DW_OP_stack_value               HEX: 9f


CONSTANT: DW_OP_lo_user                   HEX: e0
CONSTANT: DW_OP_GNU_push_tls_address      HEX: e0
CONSTANT: DW_OP_HP_unknown                HEX: e0
CONSTANT: DW_OP_HP_is_value               HEX: e1
CONSTANT: DW_OP_HP_fltconst4              HEX: e2
CONSTANT: DW_OP_HP_fltconst8              HEX: e3
CONSTANT: DW_OP_HP_mod_range              HEX: e4
CONSTANT: DW_OP_HP_unmod_range            HEX: e5
CONSTANT: DW_OP_HP_tls                    HEX: e6
CONSTANT: DW_OP_INTEL_bit_piece           HEX: e8
CONSTANT: DW_OP_APPLE_uninit              HEX: f0
CONSTANT: DW_OP_hi_user                   HEX: ff

CONSTANT: DW_ATE_address                  HEX: 1
CONSTANT: DW_ATE_boolean                  HEX: 2
CONSTANT: DW_ATE_complex_float            HEX: 3
CONSTANT: DW_ATE_float                    HEX: 4
CONSTANT: DW_ATE_signed                   HEX: 5
CONSTANT: DW_ATE_signed_char              HEX: 6
CONSTANT: DW_ATE_unsigned                 HEX: 7
CONSTANT: DW_ATE_unsigned_char            HEX: 8
CONSTANT: DW_ATE_imaginary_float          HEX: 9
CONSTANT: DW_ATE_packed_decimal           HEX: a
CONSTANT: DW_ATE_numeric_string           HEX: b
CONSTANT: DW_ATE_edited                   HEX: c
CONSTANT: DW_ATE_signed_fixed             HEX: d
CONSTANT: DW_ATE_unsigned_fixed           HEX: e
CONSTANT: DW_ATE_decimal_float            HEX: f

CONSTANT: DW_ATE_lo_user                HEX: 80
CONSTANT: DW_ATE_ALTIUM_fract           HEX: 80
CONSTANT: DW_ATE_ALTIUM_accum           HEX: 81
CONSTANT: DW_ATE_HP_float80             HEX: 80
CONSTANT: DW_ATE_HP_complex_float80     HEX: 81
CONSTANT: DW_ATE_HP_float128            HEX: 82
CONSTANT: DW_ATE_HP_complex_float128    HEX: 83
CONSTANT: DW_ATE_HP_floathpintel        HEX: 84
CONSTANT: DW_ATE_HP_imaginary_float80   HEX: 85
CONSTANT: DW_ATE_HP_imaginary_float128  HEX: 86
CONSTANT: DW_ATE_SUN_interval_float     HEX: 91
CONSTANT: DW_ATE_SUN_imaginary_float    HEX: 92
CONSTANT: DW_ATE_hi_user                HEX: ff

CONSTANT: DW_DS_unsigned                  HEX: 01
CONSTANT: DW_DS_leading_overpunch         HEX: 02
CONSTANT: DW_DS_trailing_overpunch        HEX: 03
CONSTANT: DW_DS_leading_separate          HEX: 04
CONSTANT: DW_DS_trailing_separate         HEX: 05

CONSTANT: DW_END_default                  HEX: 00
CONSTANT: DW_END_big                      HEX: 01
CONSTANT: DW_END_little                   HEX: 02
CONSTANT: DW_END_lo_user                  HEX: 40
CONSTANT: DW_END_hi_user                  HEX: ff

CONSTANT: DW_ATCF_lo_user                 HEX: 40
CONSTANT: DW_ATCF_SUN_mop_bitfield        HEX: 41
CONSTANT: DW_ATCF_SUN_mop_spill           HEX: 42
CONSTANT: DW_ATCF_SUN_mop_scopy           HEX: 43
CONSTANT: DW_ATCF_SUN_func_start          HEX: 44
CONSTANT: DW_ATCF_SUN_end_ctors           HEX: 45
CONSTANT: DW_ATCF_SUN_branch_target       HEX: 46
CONSTANT: DW_ATCF_SUN_mop_stack_probe     HEX: 47
CONSTANT: DW_ATCF_SUN_func_epilog         HEX: 48
CONSTANT: DW_ATCF_hi_user                 HEX: ff

CONSTANT: DW_ACCESS_public                HEX: 01
CONSTANT: DW_ACCESS_protected             HEX: 02
CONSTANT: DW_ACCESS_private               HEX: 03

CONSTANT: DW_VIS_local                    HEX: 01
CONSTANT: DW_VIS_exported                 HEX: 02
CONSTANT: DW_VIS_qualified                HEX: 03

CONSTANT: DW_VIRTUALITY_none              HEX: 00
CONSTANT: DW_VIRTUALITY_virtual           HEX: 01
CONSTANT: DW_VIRTUALITY_pure_virtual      HEX: 02

CONSTANT: DW_LANG_C89                     HEX: 0001
CONSTANT: DW_LANG_C                       HEX: 0002
CONSTANT: DW_LANG_Ada83                   HEX: 0003
CONSTANT: DW_LANG_C_plus_plus             HEX: 0004
CONSTANT: DW_LANG_Cobol74                 HEX: 0005
CONSTANT: DW_LANG_Cobol85                 HEX: 0006
CONSTANT: DW_LANG_Fortran77               HEX: 0007
CONSTANT: DW_LANG_Fortran90               HEX: 0008
CONSTANT: DW_LANG_Pascal83                HEX: 0009
CONSTANT: DW_LANG_Modula2                 HEX: 000a
CONSTANT: DW_LANG_Java                    HEX: 000b
CONSTANT: DW_LANG_C99                     HEX: 000c
CONSTANT: DW_LANG_Ada95                   HEX: 000d
CONSTANT: DW_LANG_Fortran95               HEX: 000e
CONSTANT: DW_LANG_PLI                     HEX: 000f
CONSTANT: DW_LANG_ObjC                    HEX: 0010
CONSTANT: DW_LANG_ObjC_plus_plus          HEX: 0011
CONSTANT: DW_LANG_UPC                     HEX: 0012
CONSTANT: DW_LANG_D                       HEX: 0013
CONSTANT: DW_LANG_Python                  HEX: 0014
CONSTANT: DW_LANG_lo_user                 HEX: 8000
CONSTANT: DW_LANG_Mips_Assembler          HEX: 8001
CONSTANT: DW_LANG_Upc                     HEX: 8765
CONSTANT: DW_LANG_ALTIUM_Assembler        HEX: 9101 
CONSTANT: DW_LANG_SUN_Assembler           HEX: 9001
CONSTANT: DW_LANG_hi_user                 HEX: ffff

CONSTANT: DW_ID_case_sensitive            HEX: 00
CONSTANT: DW_ID_up_case                   HEX: 01
CONSTANT: DW_ID_down_case                 HEX: 02
CONSTANT: DW_ID_case_insensitive          HEX: 03

CONSTANT: DW_CC_normal                    HEX: 01
CONSTANT: DW_CC_program                   HEX: 02
CONSTANT: DW_CC_nocall                    HEX: 03

CONSTANT: DW_CC_lo_user                   HEX: 40
CONSTANT: DW_CC_ALTIUM_interrupt          HEX: 65 
CONSTANT: DW_CC_ALTIUM_near_system_stack  HEX: 66 
CONSTANT: DW_CC_ALTIUM_near_user_stack    HEX: 67 
CONSTANT: DW_CC_ALTIUM_huge_user_stack    HEX: 68 
CONSTANT: DW_CC_hi_user                   HEX: ff

CONSTANT: DW_INL_not_inlined              HEX: 00
CONSTANT: DW_INL_inlined                  HEX: 01
CONSTANT: DW_INL_declared_not_inlined     HEX: 02
CONSTANT: DW_INL_declared_inlined         HEX: 03

CONSTANT: DW_ORD_row_major                HEX: 00
CONSTANT: DW_ORD_col_major                HEX: 01

CONSTANT: DW_DSC_label                    HEX: 00
CONSTANT: DW_DSC_range                    HEX: 01

CONSTANT: DW_LNS_copy                     HEX: 01
CONSTANT: DW_LNS_advance_pc               HEX: 02
CONSTANT: DW_LNS_advance_line             HEX: 03
CONSTANT: DW_LNS_set_file                 HEX: 04
CONSTANT: DW_LNS_set_column               HEX: 05
CONSTANT: DW_LNS_negate_stmt              HEX: 06
CONSTANT: DW_LNS_set_basic_block          HEX: 07
CONSTANT: DW_LNS_const_add_pc             HEX: 08
CONSTANT: DW_LNS_fixed_advance_pc         HEX: 09
CONSTANT: DW_LNS_set_prologue_end         HEX: 0a
CONSTANT: DW_LNS_set_epilogue_begin       HEX: 0b
CONSTANT: DW_LNS_set_isa                  HEX: 0c

CONSTANT: DW_LNE_end_sequence             HEX: 01
CONSTANT: DW_LNE_set_address              HEX: 02
CONSTANT: DW_LNE_define_file              HEX: 03
CONSTANT: DW_LNE_set_discriminator        HEX: 04 

CONSTANT: DW_LNE_HP_negate_is_UV_update       HEX: 11
CONSTANT: DW_LNE_HP_push_context              HEX: 12
CONSTANT: DW_LNE_HP_pop_context               HEX: 13
CONSTANT: DW_LNE_HP_set_file_line_column      HEX: 14
CONSTANT: DW_LNE_HP_set_routine_name          HEX: 15
CONSTANT: DW_LNE_HP_set_sequence              HEX: 16
CONSTANT: DW_LNE_HP_negate_post_semantics     HEX: 17
CONSTANT: DW_LNE_HP_negate_function_exit      HEX: 18
CONSTANT: DW_LNE_HP_negate_front_end_logical  HEX: 19
CONSTANT: DW_LNE_HP_define_proc               HEX: 20

CONSTANT: DW_LNE_lo_user                  HEX: 80
CONSTANT: DW_LNE_hi_user                  HEX: ff

CONSTANT: DW_MACINFO_define               HEX: 01
CONSTANT: DW_MACINFO_undef                HEX: 02
CONSTANT: DW_MACINFO_start_file           HEX: 03
CONSTANT: DW_MACINFO_end_file             HEX: 04
CONSTANT: DW_MACINFO_vendor_ext           HEX: ff

CONSTANT: DW_CFA_advance_loc        HEX: 40
CONSTANT: DW_CFA_offset             HEX: 80
CONSTANT: DW_CFA_restore            HEX: c0
CONSTANT: DW_CFA_extended           HEX: 00

CONSTANT: DW_CFA_nop              HEX: 00
CONSTANT: DW_CFA_set_loc          HEX: 01
CONSTANT: DW_CFA_advance_loc1     HEX: 02
CONSTANT: DW_CFA_advance_loc2     HEX: 03
CONSTANT: DW_CFA_advance_loc4     HEX: 04
CONSTANT: DW_CFA_offset_extended  HEX: 05
CONSTANT: DW_CFA_restore_extended HEX: 06
CONSTANT: DW_CFA_undefined        HEX: 07
CONSTANT: DW_CFA_same_value       HEX: 08
CONSTANT: DW_CFA_register         HEX: 09
CONSTANT: DW_CFA_remember_state   HEX: 0a
CONSTANT: DW_CFA_restore_state    HEX: 0b
CONSTANT: DW_CFA_def_cfa          HEX: 0c
CONSTANT: DW_CFA_def_cfa_register HEX: 0d
CONSTANT: DW_CFA_def_cfa_offset   HEX: 0e
CONSTANT: DW_CFA_def_cfa_expression HEX: 0f
CONSTANT: DW_CFA_expression       HEX: 10
CONSTANT: DW_CFA_offset_extended_sf HEX: 11
CONSTANT: DW_CFA_def_cfa_sf       HEX: 12
CONSTANT: DW_CFA_def_cfa_offset_sf HEX: 13
CONSTANT: DW_CFA_val_offset        HEX: 14
CONSTANT: DW_CFA_val_offset_sf     HEX: 15
CONSTANT: DW_CFA_val_expression    HEX: 16

CONSTANT: DW_CFA_lo_user           HEX: 1c
CONSTANT: DW_CFA_MIPS_advance_loc8 HEX: 1d
CONSTANT: DW_CFA_GNU_window_save   HEX: 2d
CONSTANT: DW_CFA_GNU_args_size     HEX: 2e
CONSTANT: DW_CFA_GNU_negative_offset_extended  HEX: 2f
CONSTANT: DW_CFA_high_user         HEX: 3f

CONSTANT: DW_EH_PE_absptr   HEX: 00
CONSTANT: DW_EH_PE_uleb128  HEX: 01
CONSTANT: DW_EH_PE_udata2   HEX: 02
CONSTANT: DW_EH_PE_udata4   HEX: 03
CONSTANT: DW_EH_PE_udata8   HEX: 04
CONSTANT: DW_EH_PE_sleb128  HEX: 09
CONSTANT: DW_EH_PE_sdata2   HEX: 0A
CONSTANT: DW_EH_PE_sdata4   HEX: 0B
CONSTANT: DW_EH_PE_sdata8   HEX: 0C
CONSTANT: DW_EH_PE_pcrel    HEX: 10
CONSTANT: DW_EH_PE_textrel  HEX: 20
CONSTANT: DW_EH_PE_datarel  HEX: 30
CONSTANT: DW_EH_PE_funcrel  HEX: 40
CONSTANT: DW_EH_PE_aligned  HEX: 50
CONSTANT: DW_EH_PE_omit     HEX: ff

CONSTANT: DW_FRAME_CFA_COL 0  

CONSTANT: DW_FRAME_REG1   1
CONSTANT: DW_FRAME_REG2   2
CONSTANT: DW_FRAME_REG3   3
CONSTANT: DW_FRAME_REG4   4
CONSTANT: DW_FRAME_REG5   5
CONSTANT: DW_FRAME_REG6   6
CONSTANT: DW_FRAME_REG7   7
CONSTANT: DW_FRAME_REG8   8
CONSTANT: DW_FRAME_REG9   9
CONSTANT: DW_FRAME_REG10  10
CONSTANT: DW_FRAME_REG11  11
CONSTANT: DW_FRAME_REG12  12
CONSTANT: DW_FRAME_REG13  13
CONSTANT: DW_FRAME_REG14  14
CONSTANT: DW_FRAME_REG15  15
CONSTANT: DW_FRAME_REG16  16
CONSTANT: DW_FRAME_REG17  17
CONSTANT: DW_FRAME_REG18  18
CONSTANT: DW_FRAME_REG19  19
CONSTANT: DW_FRAME_REG20  20
CONSTANT: DW_FRAME_REG21  21
CONSTANT: DW_FRAME_REG22  22
CONSTANT: DW_FRAME_REG23  23
CONSTANT: DW_FRAME_REG24  24
CONSTANT: DW_FRAME_REG25  25
CONSTANT: DW_FRAME_REG26  26
CONSTANT: DW_FRAME_REG27  27
CONSTANT: DW_FRAME_REG28  28
CONSTANT: DW_FRAME_REG29  29
CONSTANT: DW_FRAME_REG30  30
CONSTANT: DW_FRAME_REG31  31
CONSTANT: DW_FRAME_FREG0  32
CONSTANT: DW_FRAME_FREG1  33
CONSTANT: DW_FRAME_FREG2  34
CONSTANT: DW_FRAME_FREG3  35
CONSTANT: DW_FRAME_FREG4  36
CONSTANT: DW_FRAME_FREG5  37
CONSTANT: DW_FRAME_FREG6  38
CONSTANT: DW_FRAME_FREG7  39
CONSTANT: DW_FRAME_FREG8  40
CONSTANT: DW_FRAME_FREG9  41
CONSTANT: DW_FRAME_FREG10 42
CONSTANT: DW_FRAME_FREG11 43
CONSTANT: DW_FRAME_FREG12 44
CONSTANT: DW_FRAME_FREG13 45
CONSTANT: DW_FRAME_FREG14 46
CONSTANT: DW_FRAME_FREG15 47
CONSTANT: DW_FRAME_FREG16 48
CONSTANT: DW_FRAME_FREG17 49
CONSTANT: DW_FRAME_FREG18 50
CONSTANT: DW_FRAME_FREG19 51
CONSTANT: DW_FRAME_FREG20 52
CONSTANT: DW_FRAME_FREG21 53
CONSTANT: DW_FRAME_FREG22 54
CONSTANT: DW_FRAME_FREG23 55
CONSTANT: DW_FRAME_FREG24 56
CONSTANT: DW_FRAME_FREG25 57
CONSTANT: DW_FRAME_FREG26 58
CONSTANT: DW_FRAME_FREG27 59
CONSTANT: DW_FRAME_FREG28 60
CONSTANT: DW_FRAME_FREG29 61
CONSTANT: DW_FRAME_FREG30 62
CONSTANT: DW_FRAME_FREG31 63

CONSTANT: DW_CHILDREN_no        HEX: 00
CONSTANT: DW_CHILDREN_yes       HEX: 01
CONSTANT: DW_ADDR_none          HEX: 00
