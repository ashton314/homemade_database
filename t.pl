#!/usr/bin/env perl
use strict;
use warnings;

use Btree;
use Test::More;
use Data::Dumper;

my $tree0 = Btree->new();

$tree0->insert('a');
$tree0->insert('b');
is_deeply($tree0->{keys}, ['a', 'b'], 'keys inserted a, b correct');
is_deeply($tree0->{values}, ['a', 'b'], 'values inserted a, b correct');

$tree0 = Btree->new();
$tree0->insert('b');
$tree0->insert('a');
is_deeply($tree0->{keys}, ['a', 'b'], 'keys inserted a, b correct');
is_deeply($tree0->{values}, ['a', 'b'], 'values inserted a, b correct');

done_testing();
