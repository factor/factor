namespace factor
{

struct nursery_space : bump_allocator<object>
{
	explicit nursery_space(cell size, cell start) : bump_allocator<object>(size,start) {}
};

}
