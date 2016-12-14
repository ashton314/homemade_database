#!/usr/bin/env perl
use strict;
use warnings;

no warnings "experimental::lexical_subs";
use feature 'lexical_subs';	# because Lisp

use Btree;
use Test::More;
use Data::Dumper;
# use Mojo::JSON;

# sub dense_hash {
#   return Mojo::JSON::to_json(+shift);
# }

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

tree_print_tall($tree0->{head_node});

done_testing();

sub tree_print_tall {
  my ($node, $indent) = @_;
  $indent //= 0;
  my @k = reverse @{$node->{keys}}; my @v = reverse @{$node->{values}};
  my $h = int (scalar @v) / 2;

  if ($node->{leaf}) {
    local $" = ' ';
    print '   ' x $indent . "--\n";
    print '   ' x $indent . "$_\n" foreach @v;
    print '   ' x $indent . "--\n";
  }
  else {
    for my $i (0..$#k) {
      tree_print_tall($v[$i], $indent + 1);
      print '   ' x $indent . $k[$i] . "\n";
    }
    tree_print_tall($v[$#v], $indent + 1);
  }
}

sub tree_print_wide {
  my $node = shift;


  my sub tree_walker {
    my @vals = @{+shift};
    my ($width, @acc) = tree_walker($node->{values});
    ...;
  }

  ...;

}
