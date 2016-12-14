#!/usr/bin/env perl
use strict;
use warnings;

use Test::More tests => 13;

BEGIN { push @INC, '../'; }

use Btree;
use Data::Dumper;

diag('testing find_bisect');
is(Btree::Node::find_bisect('c', [qw(a b d e f)]), 2, 'find_bisect: nonexistent, middle of set');
is(Btree::Node::find_bisect('c', [qw(a b c d e f)]), 2, 'find_bisect: existent, middle of set');
is(Btree::Node::find_bisect('a', [qw(b c d e f)]), 0, 'find_bisect: nonexistent, beginning of set');
is(Btree::Node::find_bisect('a', [qw(a b c d e f)]), 0, 'find_bisect: existent, beginning of set');
is(Btree::Node::find_bisect('f', [qw(a b c d e)]), 5, 'find_bisect: nonexistent, end of set');
is(Btree::Node::find_bisect('f', [qw(a b c d e f)]), 5, 'find_bisect: existent, end of set');

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

