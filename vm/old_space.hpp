namespace factor
{

static const cell card_starts_inside_object = 0xff;

struct old_space : zone {
	card *object_start_offsets;
	card *object_start_offsets_end;

	old_space(cell size_, cell start_);
	~old_space();

	cell first_object_in_card(cell card_index);
	cell find_object_containing_card(cell card_index);
	void record_object_start_offset(object *obj);
	object *allot(cell size);
	void clear_object_start_offsets();
	cell next_object_after(factor_vm *parent, cell scan);
};

}
