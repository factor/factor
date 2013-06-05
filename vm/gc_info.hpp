namespace factor {

struct gc_info {
  uint32_t scrub_d_count;
  uint32_t scrub_r_count;
  uint32_t gc_root_count;
  uint32_t derived_root_count;
  uint32_t return_address_count;

  cell callsite_bitmap_size() {
    return scrub_d_count + scrub_r_count + gc_root_count;
  }

  cell total_bitmap_size() {
    return return_address_count * callsite_bitmap_size();
  }

  cell total_bitmap_bytes() { return ((total_bitmap_size() + 7) / 8); }

  uint32_t* return_addresses() {
    return (uint32_t*)this - return_address_count;
  }

  uint32_t* base_pointer_map() {
    return return_addresses() - return_address_count * derived_root_count;
  }

  uint8_t* gc_info_bitmap() {
    return (uint8_t*)base_pointer_map() - total_bitmap_bytes();
  }

  cell callsite_scrub_d(cell index) { return index * scrub_d_count; }

  cell callsite_scrub_r(cell index) {
    return return_address_count * scrub_d_count + index * scrub_r_count;
  }

  cell callsite_gc_roots(cell index) {
    return return_address_count * scrub_d_count +
           return_address_count * scrub_r_count + index * gc_root_count;
  }

  uint32_t lookup_base_pointer(cell index, cell derived_root) {
    return base_pointer_map()[index * derived_root_count + derived_root];
  }

  cell return_address_index(cell return_address);
};

}
