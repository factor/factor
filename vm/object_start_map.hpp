namespace factor {

static const cell card_starts_inside_object = 0xff;

struct object_start_map {
  cell size, start;
  card* object_start_offsets;
  card* object_start_offsets_end;

  object_start_map(cell size, cell start);
  ~object_start_map();

  cell find_object_containing_card(cell card_index);
  void record_object_start_offset(object* obj);
  void clear_object_start_offsets();
  void update_card_for_sweep(cell index, uint16_t mask);
  void update_for_sweep(mark_bits* state);
};

}
