namespace factor
{

struct allot_marker {
	char first_object_start;
	char last_object_start;
};

struct old_space : zone {
	card *allot_markers;
	card *allot_markers_end;

	old_space(cell size_, cell start_);
	~old_space();

	cell first_object_in_card(cell address)
	{
		return allot_markers[(address - start) >> card_bits];
	}

	card *addr_to_allot_marker(object *a);
	void record_allocation(object *obj);
	object *allot(cell size);
	void clear_allot_markers();
	cell next_object_after(factor_vm *myvm, cell scan);
};

}
