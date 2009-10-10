namespace factor
{

static const cell card_starts_inside_object = 0xff;

struct old_space : zone {
	card *object_start_offsets;
	card *object_start_offsets_end;

	old_space(cell size_, cell start_);
	~old_space();

	cell object_start_map_index(cell address)
	{
		return (address - start) >> card_bits;
	}

	/* Find the first object starting on or after the given address */
	cell first_object_in_card(cell address)
	{
		return object_start_offsets[object_start_map_index(address)];
	}

	/* Find the card which contains the header of the object which contains
	the given address */
	cell find_card_containing_header(cell address)
	{
		cell i = object_start_map_index(address);
		while(i >= 0 && object_start_offsets[i] == card_starts_inside_object) i--;
		return i;
	}

	void record_object_start_offset(object *obj);
	object *allot(cell size);
	void clear_object_start_offsets();
	cell next_object_after(factor_vm *myvm, cell scan);
};

}
