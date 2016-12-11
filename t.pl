#!/usr/bin/env perl
use strict;
use warnings;

use Btree;
use Test::More;
use Data::Dumper;

my $tree0 = Btree->new();

diag("Function tests");
is_deeply([Btree::Node::insert_at(['b', 'c', 'd'], 'a', 0)], [qw(a b c d)], "insert_at: insertion at 0 correct");
is_deeply([Btree::Node::insert_at(['a', 'c', 'd'], 'b', 1)], [qw(a b c d)], "insert_at: insertion at 1 correct");
is_deeply([Btree::Node::insert_at(['a', 'b', 'd'], 'c', 2)], [qw(a b c d)], "insert_at: insertion at 2 correct");
is_deeply([Btree::Node::insert_at(['a', 'b', 'c'], 'd', 3)], [qw(a b c d)], "insert_at: insertion at 3 correct");
diag("END Function tests\n\nTree tests");


$tree0->insert('a');
$tree0->insert('b');
is_deeply($tree0->{head_node}->{keys}, ['a', 'b'], 'keys inserted a, b correct');
is_deeply($tree0->{head_node}->{values}, ['a', 'b'], 'values inserted a, b correct');


$tree0 = Btree->new(max_degree => 2);
$tree0->insert('b');
$tree0->insert('a');
is_deeply($tree0->{head_node}->{keys}, ['a', 'b'], 'keys inserted a, b correct');
is_deeply($tree0->{head_node}->{values}, ['a', 'b'], 'values inserted a, b correct');

$tree0->insert('d');

is_deeply($tree0->to_hash, { keys   => ['b'],
			     values => [ { keys => ['a'], values => ['a'] },
					 { keys => ['b', 'd'], values => ['b', 'd']} ] },
	  'inserted d and split correctly');

$tree0->insert('c');
is_deeply($tree0->to_hash, { keys   => ['b', 'd'],
			     values => [ { keys => ['a'], values => ['a'] },
					 { keys => ['b', 'c'], values => ['b', 'c']},
					 { keys => ['d'], values => ['d'] } ] },
	  'inserted c correctly, split correctly again');

$tree0->insert('aa');
is_deeply($tree0->to_hash, { keys   => ['b', 'd'],
			     values => [ { keys => ['a', 'aa'], values => ['a', 'aa'] },
					 { keys => ['b', 'c'], values => ['b', 'c']},
					 { keys => ['d'], values => ['d'] } ] },
	  'inserted aa correctly');

print Dumper($tree0->to_hash);

print "-" x 80; print "\n";

$tree0->insert('ab');
# is_deeply($tree0->to_hash, { keys   => ['b', 'd'],
# 			     values => [ { keys => ['a', 'aa'], values => ['a', 'aa'] },
# 					 { keys => ['b', 'c'], values => ['b', 'c']},
# 					 { keys => ['d'], values => ['d'] } ] },
# 	  'inserted ab correctly');

print Dumper($tree0->to_hash);
done_testing();
