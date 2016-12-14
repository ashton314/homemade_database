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

diag('testing tree functions');
