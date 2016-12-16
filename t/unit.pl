#!/usr/bin/env perl
use strict;
use warnings;

use Test::More; # tests => 36;

BEGIN { push @INC, '../'; }

use Btree;
use Data::Dumper;
use List::Util 'all';

diag('testing find_bisect');
is(Btree::Node::find_bisect('c', [qw(a b d e f)]), 2, 'find_bisect: nonexistent, middle of set');
is(Btree::Node::find_bisect('c', [qw(a b c d e f)]), 3, 'find_bisect: existent, middle of set');
is(Btree::Node::find_bisect('a', [qw(b c d e f)]), 0, 'find_bisect: nonexistent, beginning of set');
is(Btree::Node::find_bisect('a', [qw(a b c d e f)]), 1, 'find_bisect: existent, beginning of set');
is(Btree::Node::find_bisect('f', [qw(a b c d e)]), 5, 'find_bisect: nonexistent, end of set');
is(Btree::Node::find_bisect('f', [qw(a b c d e f)]), 6, 'find_bisect: existent, end of set');

diag('testing insert_at');
is_deeply([Btree::Node::insert_at(['b', 'c', 'd'], 'a', 0)], [qw(a b c d)], "insert_at: insertion at 0 correct");
is_deeply([Btree::Node::insert_at(['a', 'c', 'd'], 'b', 1)], [qw(a b c d)], "insert_at: insertion at 1 correct");
is_deeply([Btree::Node::insert_at(['a', 'b', 'd'], 'c', 2)], [qw(a b c d)], "insert_at: insertion at 2 correct");
is_deeply([Btree::Node::insert_at(['a', 'b', 'c'], 'd', 3)], [qw(a b c d)], "insert_at: insertion at 3 correct");
is_deeply([Btree::Node::insert_at(['b', 'c'], 'a', 0)], [qw(a b c)], "insert_at: insertion at 0 correct (odd set)");
is_deeply([Btree::Node::insert_at(['a', 'c'], 'b', 1)], [qw(a b c)], "insert_at: insertion at 1 correct (odd set)");
is_deeply([Btree::Node::insert_at(['a', 'b'], 'c', 2)], [qw(a b c)], "insert_at: insertion at 2 correct (odd set)");

diag('testing _find_leaf');
my $leaf0 = Btree::Node->new(leaf	=> 1,
			     max_degree => 4,
			     keys	=> [qw(a b)],
			     values	=> [qw(a b)]);
my $leaf1 = Btree::Node->new(leaf	=> 1,
			     max_degree => 4,
			     keys	=> [qw(c d)],
			     values	=> [qw(c d)]);
my $leaf2 = Btree::Node->new(leaf	=> 1,
			     max_degree => 4,
			     keys	=> [qw(e f)],
			     values	=> [qw(e f)]);
my $leaf3 = Btree::Node->new(leaf	=> 1,
			     max_degree => 4,
			     keys	=> [qw(g h)],
			     values	=> [qw(g h)]);
my $leaf4 = Btree::Node->new(leaf	=> 1,
			     max_degree => 4,
			     keys	=> [qw(i j k)],
			     values	=> [qw(i j k)]);
$leaf0->{next_leaf} = $leaf1;
$leaf1->{next_leaf} = $leaf2;
$leaf2->{next_leaf} = $leaf3;
$leaf3->{next_leaf} = $leaf4;

my $idx0 = Btree::Node->new(leaf       => 0,
			    max_degree => 4,
			    keys       => [qw(c e)],
			    values     => [$leaf0, $leaf1, $leaf2]);
$_->{parent} = $idx0 foreach @{$idx0->{values}};

my $idx1 = Btree::Node->new(leaf       => 0,
			    max_degree => 4,
			    keys       => [qw(i)],
			    values     => [$leaf3, $leaf4]);
$_->{parent} = $idx1 foreach @{$idx1->{values}};
$idx0->{next_leaf} = $idx1;

my $head0 = Btree::Node->new(leaf       => 0,
			     max_degree => 4,
			     keys       => [qw(g)],
			     values     => [$idx0, $idx1]);
$idx0->{parent} = $head0;
$idx1->{parent} = $head0;

my $tree1 = Btree->new(max_degree => 4);
$tree1->insert($_) foreach 'a'..'k';
is_deeply($head0->to_hash(), $tree1->to_hash(), 'built tree(4) for a..k correctly');

# diag("leaf0: $leaf0\nleaf1: $leaf1\nleaf2: $leaf2\nleaf3: $leaf3\n");
# diag("idx0: $idx0\nidx1: $idx1\nhead0: $head0\n");

is(Btree::Node::_find_leaf($head0, 'a'), $leaf0, '_find_leaf: found for a (existent)');
is(Btree::Node::_find_leaf($head0, 'b'), $leaf0, '_find_leaf: found for b (existent)');
is(Btree::Node::_find_leaf($head0, 'c'), $leaf1, '_find_leaf: found for c (existent)');
is(Btree::Node::_find_leaf($head0, 'd'), $leaf1, '_find_leaf: found for d (existent)');
is(Btree::Node::_find_leaf($head0, 'e'), $leaf2, '_find_leaf: found for e (existent)');
is(Btree::Node::_find_leaf($head0, 'f'), $leaf2, '_find_leaf: found for f (existent)');
is(Btree::Node::_find_leaf($head0, 'g'), $leaf3, '_find_leaf: found for g (existent)');
is(Btree::Node::_find_leaf($head0, 'h'), $leaf3, '_find_leaf: found for h (existent)');
is(Btree::Node::_find_leaf($head0, 'i'), $leaf4, '_find_leaf: found for i (existent)');
is(Btree::Node::_find_leaf($head0, 'j'), $leaf4, '_find_leaf: found for j (existent)');
is(Btree::Node::_find_leaf($head0, 'k'), $leaf4, '_find_leaf: found for k (existent)');

is(Btree::Node::_find_leaf($head0, 'aa'), $leaf0, '_find_leaf: found for aa (non-existent)');
is(Btree::Node::_find_leaf($head0, 'ba'), $leaf0, '_find_leaf: found for ba (non-existent)');
is(Btree::Node::_find_leaf($head0, 'ca'), $leaf1, '_find_leaf: found for ca (non-existent)');
is(Btree::Node::_find_leaf($head0, 'da'), $leaf1, '_find_leaf: found for da (non-existent)');
is(Btree::Node::_find_leaf($head0, 'ea'), $leaf2, '_find_leaf: found for ea (non-existent)');
is(Btree::Node::_find_leaf($head0, 'fa'), $leaf2, '_find_leaf: found for fa (non-existent)');
is(Btree::Node::_find_leaf($head0, 'ga'), $leaf3, '_find_leaf: found for ga (non-existent)');
is(Btree::Node::_find_leaf($head0, 'ha'), $leaf3, '_find_leaf: found for ha (non-existent)');
is(Btree::Node::_find_leaf($head0, 'ia'), $leaf4, '_find_leaf: found for ia (non-existent)');
is(Btree::Node::_find_leaf($head0, 'ja'), $leaf4, '_find_leaf: found for ja (non-existent)');
is(Btree::Node::_find_leaf($head0, 'ka'), $leaf4, '_find_leaf: found for ka (non-existent)');
is(Btree::Node::_find_leaf($head0, 'l'),  $leaf4, '_find_leaf: found for l  (non-existent)');

diag('linkage testing');
my $head1  = $tree1->{head_node};
my @idxs1  = @{ $head1->{values} };
my @leafs1 = map { @{ $_->{values} } } @idxs1;

my $i = 0;
foreach (@leafs1[0..2]) {
  is($_->{parent}, $idxs1[0], "linkage: ${i}th leaf's parent is correct");
  $i++;
}

foreach (@leafs1[3..4]) {
  is($_->{parent}, $idxs1[1], "linkage: ${i}th leaf's parent is correct");
  $i++;
}
is($_->{parent}, $head1, 'linkage: index node\'s parent is correct')
  foreach @idxs1;

diag('testing _split');
my $node0 = Btree::Node->new(leaf	=> 1,
			     parent	=> undef,
			     values	=> [qw(a b c)],
			     keys	=> [qw(a b c)],
			     max_degree => 3);
my $node1 = Btree::Node->new(leaf	=> 1,
			     parent	=> undef,
			     values	=> [qw(a b c d)],
			     keys	=> [qw(a b c d)],
			     max_degree => 4);


Btree::Node::_split($node0);
Btree::Node::_split($node1);

for my $n ($node0, $node1) {
  my $parent0 = $n->{parent};
  ok(defined $parent0, '_split: node(3) got a parent');
  is(ref $parent0, 'Btree::Node', '_split: node(3)\'s parent is a node');
  is($parent0->{leaf}, 0, '_split: node(3).parent.leaf is false');
  is($parent0->{values}->[0], $n, '_split: n is the parent\'s first child');

  my $n1 = $n->{next_leaf};
  is(ref $n1, 'Btree::Node', '_split: n\'s next_node slot is a node');
  is($n1, $parent0->{values}->[1], "_split: n's next_node slot eq to parent's value");
  is($n1->{next_leaf}, undef, '_split: n1 does not pretend to have a next_leaf');
  is($n1->{parent}, $parent0, "_split: n1's parent is correct");
}
is_deeply($node0->{keys}, [qw(a)], '_split: left node(3) has correct keys');
is_deeply($node0->{values}, [qw(a)], '_split: left node(3) has correct values');
is_deeply($node0->{next_leaf}->{keys}, [qw(b c)], '_split: right node(3) has correct keys');
is_deeply($node0->{next_leaf}->{values}, [qw(b c)], '_split: right node(3) has correct values');

is_deeply($node1->{keys}, [qw(a b)], '_split: left node(4) has correct keys');
is_deeply($node1->{values}, [qw(a b)], '_split: left node(4) has correct values');
is_deeply($node1->{next_leaf}->{keys}, [qw(c d)], '_split: right node(4) has correct keys');
is_deeply($node1->{next_leaf}->{values}, [qw(c d)], '_split: right node4) has correct values');

{
  my $leaf0 = Btree::Node->new(leaf	  => 1,
			       max_degree => 4,
			       keys	  => [qw(a b)],
			       values	  => [qw(a b)]);
  my $leaf1 = Btree::Node->new(leaf	  => 1,
			       max_degree => 4,
			       keys	  => [qw(c d)],
			       values	  => [qw(c d)]);
  my $leaf2 = Btree::Node->new(leaf	  => 1,
			       max_degree => 4,
			       keys	  => [qw(e f)],
			       values	  => [qw(e f)]);
  my $leaf3 = Btree::Node->new(leaf	  => 1,
			       max_degree => 4,
			       keys	  => [qw(g h)],
			       values	  => [qw(g h)]);

  $leaf0->{next_leaf} = $leaf1;
  $leaf1->{next_leaf} = $leaf2;
  $leaf2->{next_leaf} = $leaf3;

  my $idx0 = Btree::Node->new(leaf       => 0,
			      parent     => undef,
			      max_degree => 3,
			      keys       => [qw(c e g)],
			      values     => [$leaf0, $leaf1, $leaf2, $leaf3]);
  $_->{parent} = $idx0 foreach @{$idx0->{values}};

  Btree::Node::_split($idx0);

  my $head = $idx0->{parent};
  my $idx1 = $idx0->{next_leaf};
  ok(defined $head, '_split: idx0 has a parent');
  ok(defined $idx1, '_split: idx0 has a sibbling');

  is_deeply($head->{keys}, [qw(e)], '_split: head node has correct keys');
  is_deeply($head->{values}, [$idx0, $idx1], '_split: head has correct children');
  is($idx1->{parent}, $head, '_split: new idx node knows its parent');

  is_deeply($idx0->{keys}, [qw(c)], '_split: idx0 has correct keys');
  is_deeply($idx0->{values}, [$leaf0, $leaf1], '_split: idx0 has correct children');

  is_deeply($idx1->{keys}, [qw(g)], '_split: idx1 has correct keys');
  is_deeply($idx1->{values}, [$leaf2, $leaf3], '_split: idx1 has correct children');

  ok((all { $_->{parent} eq $idx0 } @{$idx0->{values}}), "_split: idx0's children's link to parent correct");
  ok((all { $_->{parent} eq $idx1 } @{$idx1->{values}}), "_split: idx1's children's link to parent correct");
}

done_testing();
