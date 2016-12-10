Bug Listing
===========

This is a listing of all the major bugs I find so I don't forget about
them.

### Insert-clobber Bug

This doesn't work:

	my $tree = Btree->new();

	map { $tree->insert($_) } qw(a b d c);

`d` seems to get clobbered.


### Head node split bug

I can't get this to work either:

	my $tree = Btree->new();

	map { $tree->insert($_) } qw(a b c d aa ab);

The program *really* doesn't like the insertion of `ab`. Trying to
insert that into the head node doesn't work.

When splitting an index node, I think I need to put all of the values
together, then split the thing.

Right now in the code I figure out where I need to split, then
insert. Perhaps I should try inserting first, then split.

That would also ensure the order of some leaf nodes matches with a
demo I found online.
