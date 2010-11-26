namespace factor
{

struct gc_info {
	u32 scrub_d_count;
	u32 scrub_r_count;
	u32 gc_root_count;
	u32 derived_root_count;
	u32 return_address_count;

	cell callsite_bitmap_size()
	{
		return scrub_d_count + scrub_r_count + gc_root_count;
	}

	cell total_bitmap_size()
	{
		return return_address_count * callsite_bitmap_size();
	}

	cell total_bitmap_bytes()
	{
		return ((total_bitmap_size() + 7) / 8);
	}

	u32 *return_addresses()
	{
		return (u32 *)this - return_address_count;
	}

	u32 *base_pointer_map()
	{
		return return_addresses() - return_address_count * derived_root_count;
	}

	u8 *gc_info_bitmap()
	{
		return (u8 *)base_pointer_map() - total_bitmap_bytes();
	}

	cell callsite_scrub_d(cell index)
	{
		return index * scrub_d_count;
	}

	cell callsite_scrub_r(cell index)
	{
		return return_address_count * scrub_d_count +
			index * scrub_r_count;
	}

	cell callsite_gc_roots(cell index)
	{
		return return_address_count * scrub_d_count
			+ return_address_count * scrub_r_count
			+ index * gc_root_count;
	}

	u32 lookup_base_pointer(cell index, cell derived_root)
	{
		return base_pointer_map()[index * derived_root_count + derived_root];
	}

	cell return_address_index(cell return_address);
};

}
