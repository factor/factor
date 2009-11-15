namespace factor
{

static const cell card_starts_inside_object = 0xff;

struct object_start_map {
	cell size, start;
	card *object_start_offsets;
	card *object_start_offsets_end;

	explicit object_start_map(cell size_, cell start_);
	~object_start_map();

	cell first_object_in_card(cell card_index);
	cell find_object_containing_card(cell card_index);
	void record_object_start_offset(object *obj);
	void clear_object_start_offsets();
	void update_card_for_sweep(cell index, u16 mask);
	void update_for_sweep(mark_bits<object> *state);
};

}
