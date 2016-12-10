#!/usr/bin/env perl
use strict;
use warnings;

use Btree;
use Test::More;
use Data::Dumper;

my $tree0 = Btree->new();

$tree0->insert('a');
$tree0->insert('b');
is_deeply($tree0->{head_node}->{keys}, ['a', 'b'], 'keys inserted a, b correct');
is_deeply($tree0->{head_node}->{values}, ['a', 'b'], 'values inserted a, b correct');



$tree0 = Btree->new(max_degree => 2);
$tree0->insert('b');
$tree0->insert('a');
is_deeply($tree0->{head_node}->{keys}, ['a', 'b'], 'keys inserted a, b correct');
is_deeply($tree0->{head_node}->{values}, ['a', 'b'], 'values inserted a, b correct');

$tree0->insert('c');

is_deeply($tree0->to_hash, { keys   => ['b'],
			     values => [ { keys => ['a'], values => ['a'] },
					 { keys => ['b', 'c'], values => ['b', 'c']} ] },
	  'inserted c and split correctly');

$tree0->insert('d');
print Dumper($tree0->to_hash);

done_testing();
