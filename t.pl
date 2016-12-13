#!/usr/bin/env perl
use strict;
use warnings;

use Btree;
use Test::More;
use Data::Dumper;
use Mojo::JSON;

my $tree0 = Btree->new();

diag("\nFunction tests\n");
is_deeply([Btree::Node::insert_at(['b', 'c', 'd'], 'a', 0)], [qw(a b c d)], "insert_at: insertion at 0 correct");
is_deeply([Btree::Node::insert_at(['a', 'c', 'd'], 'b', 1)], [qw(a b c d)], "insert_at: insertion at 1 correct");
is_deeply([Btree::Node::insert_at(['a', 'b', 'd'], 'c', 2)], [qw(a b c d)], "insert_at: insertion at 2 correct");
is_deeply([Btree::Node::insert_at(['a', 'b', 'c'], 'd', 3)], [qw(a b c d)], "insert_at: insertion at 3 correct");
diag("\nEND Function tests\n\nTree tests\n");


$tree0->insert('a');
$tree0->insert('b');
is_deeply($tree0->{head_node}->{keys}, ['a', 'b'], 'keys inserted a, b correct');
is_deeply($tree0->{head_node}->{values}, ['a', 'b'], 'values inserted a, b correct');


$tree0 = Btree->new(max_degree => 3); # insert order: b a d c aa ab
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
is_deeply($tree0->to_hash, { keys   => ['b', 'c'],
			     values => [ { keys => ['a'], values => ['a'] },
					 { keys => ['b'], values => ['b']},
					 { keys => ['c', 'd'], values => ['c', 'd'] } ] },
	  'inserted c correctly, split correctly again');

$tree0->insert('aa');
is_deeply($tree0->to_hash, { keys   => ['b', 'c'],
			     values => [ { keys => ['a', 'aa'], values => ['a', 'aa'] },
					 { keys => ['b'], values => ['b']},
					 { keys => ['c', 'd'], values => ['c', 'd'] } ] },
	  'inserted aa correctly');

print dense_hash($tree0->to_hash);

print "\n"; print "-" x 80; print "\n";

$tree0->insert('ab');
is_deeply($tree0->to_hash, { keys   => ['b'],
			     values => [ { keys   => ['aa'],
					   values => [ { keys   => ['a'],
							 values => ['a'] },
						       { keys   => ['aa', 'ab'],
							 values => ['aa', 'ab'] } ] },
					 { keys   => ['c'],
					   values => [ { keys   => ['b'],
							 values => ['b'] },
						       { keys   => ['c', 'd'],
							 values => ['c', 'd'] } ] } ] },
	  'inserted ab correctly');

# print Dumper($tree0->to_hash);
done_testing();

sub dense_hash {
  return Mojo::JSON::to_json(+shift);
}

sub tree_print {
  my $tree = shift;
  my $node = $tree->{head_node};

  sub line_print {
    my $node = shift;

    my @line = ();
  }


}
