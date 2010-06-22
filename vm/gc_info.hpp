namespace factor
{

struct gc_info {
	int scrub_d_count;
	int scrub_r_count;
	int gc_root_count;
	int return_address_count;

	cell total_bitmap_size()
	{
		return return_address_count * (scrub_d_count + scrub_r_count + gc_root_count);
	}

	cell total_bitmap_bytes()
	{
		return ((total_bitmap_size() + 7) / 8);
	}

	u32 *return_addresses()
	{
		return (u32 *)((u8 *)this - return_address_count * sizeof(u32));
	}

	u8 *gc_info_bitmap()
	{
		return (u8 *)return_addresses() - total_bitmap_bytes();
	}

	cell scrub_d_base(cell index)
	{
		return index * scrub_d_count;
	}

	cell scrub_r_base(cell index)
	{
		return return_address_count * scrub_d_count +
			index * scrub_r_count;
	}

	cell spill_slot_base(cell index)
	{
		return return_address_count * scrub_d_count
			+ return_address_count * scrub_r_count
			+ index * gc_root_count;
	}

	int return_address_index(cell return_address);
};

}
