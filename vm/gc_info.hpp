namespace factor {

// gc_info should be kept in sync with:
//   basis/compiler/codegen/gc-maps/gc-maps.factor
//   basis/vm/vm.factor
struct gc_info {
  uint32_t gc_root_count;
  uint32_t derived_root_count;
  uint32_t return_address_count;

  cell callsite_bitmap_size() {
    return gc_root_count;
  }

  cell total_bitmap_size() {
    return return_address_count * callsite_bitmap_size();
  }

  cell total_bitmap_bytes() { return ((total_bitmap_size() + 7) / 8); }

  uint32_t* return_addresses() {
    return reinterpret_cast<uint32_t*>(this) - return_address_count;
  }

  uint32_t* base_pointer_map() {
    return return_addresses() - return_address_count * derived_root_count;
  }

  uint8_t* gc_info_bitmap() {
    return reinterpret_cast<uint8_t*>(base_pointer_map()) - total_bitmap_bytes();
  }


  cell callsite_gc_roots(cell index) {
    return index * gc_root_count;
  }

  uint32_t lookup_base_pointer(cell index, cell derived_root) {
    return base_pointer_map()[index * derived_root_count + derived_root];
  }

  cell return_address_index(cell return_address) {
    uint32_t* return_address_array = return_addresses();

    for (cell i = 0; i < return_address_count; i++) {
      if (return_address == return_address_array[i])
        return i;
    }

    return static_cast<cell>(-1);
  }
};

}
