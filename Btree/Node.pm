package Btree::Node;
use strict;
use warnings;

## TESTING
use Data::Dumper;

our $MAX_DEGREE = 3;

sub new {
  my $class = shift;

  my %args = (
	      keys	 => [],
	      values	 => [],
	      parent	 => undef,
	      next_leaf	 => undef,
	      leaf	 => 1,
	      max_degree => $MAX_DEGREE,
	      @_
	     );

  return bless \%args, $class;
}


##
## Top-level methods
##

sub insert {
  my ($self, $key, $val) = @_;
  die "Not enough arguments to sub insert: $!"
    unless defined $key;
  $val //= $key;

  if ($self->{leaf}) {
    my $node = _insert($self, $key, $val);
    return $node->_root;
  }
  else {
    # TODO: write more succinctly
    my $chld = $self->_find_leaf($key);
    my $node = _insert($chld, $key, $val);
    return $node->_root;
  }
}

sub remove {
  ...;
}

sub search {
  # use the _find_child() function
  ...;
}

sub to_string {
  my ($self, $indent) = @_;
  $indent //= 0;
  local $" = ' | ';
  my $acc = ' ' x $indent . "---\n";
  $acc .= (' ' x $indent) . "keys: @{$self->{keys}}\n";
  $acc .= (' ' x $indent) . "vals: @{$self->{keys}}\n";

  unless ($self->{leaf}) {
    # OPTIMIZE: make tail-recursive
    map { $acc .= $_->to_string($indent + 3) } @{ $self->{values} };
  }
  return $acc;
}

sub to_hash {
  my $self = shift;

  return { keys   => $self->{keys},
	   values => $self->{leaf} ? $self->{values} : [map { $_->to_hash } @{$self->{values}}] };
}

##
## Secondary functions, called by the top-level methods with no
## argument checking, etc.
##

sub _insert {
  my ($node, $key, $val) = @_;

  my $bisection = find_bisect($key, $node->{keys});

  @{$node->{keys}} = insert_at($node->{keys}, $key, $bisection);
  @{$node->{values}} = insert_at($node->{values}, $val, ($node->{leaf} ? $bisection : $bisection + 1));

  # now see if we need to split

  $node->_split() if (scalar @{$node->{keys}} >= $node->{max_degree});

  return $node;
}

sub _split {
  my ($node) = @_;

  # okay, do we need to make a new parent?
  unless (defined $node->{parent}) {
    my $new_parent = Btree::Node->new(leaf	 => 0,
				      parent	 => undef,
				      values     => [$node],
				      max_degree => $node->{max_degree});
    $node->{parent} = $new_parent;
  }

  my $half_way = int $node->{max_degree} / 2;
  my $new_node = Btree::Node->new(leaf	     => $node->{leaf},
				  parent     => $node->{parent},
				  next_leaf  => $node->{next_leaf},
				  max_degree => $node->{max_degree},
				  keys       => [splice @{$node->{keys}}, $half_way],
				  values     => [splice @{$node->{values}}, ($node->{leaf} ? $half_way : $half_way + 1)]);

  $node->{next_leaf} = $new_node;
  $node->{parent}->_insert($new_node->{keys}->[0], $new_node);

  unless ($new_node->{leaf}) {
    # map { $_->{parent} = $new_node } @{ $new_node->{values} };
    shift @{$new_node->{keys}};
  }

  # print "NEW PARENT: ";
  # print Dumper($node->{parent});
}

sub _find_leaf {
  my ($node, $key) = @_;

  if ($node->{leaf}) {
    return $node;
  }
  else {
    return $node->{values}->[find_bisect($key, $node->{keys})]->_find_leaf($key);
  }
}

sub _root {
  # given a node on a tree, return the root
  my $node = shift;
  return defined $node->{parent} ? _root($node->{parent}) : $node;
}

##
## Okay, now we start with the helper functions
##

sub insert_at {
  # given ($array_ref, $value, $index), inserts $value at position
  # $index, shifting the other values forward one space, and returning
  # a new array

  my @lst = @{ +shift };
  my ($val, $idx) = @_;

  if ($idx) {
    return (@lst[0..$idx-1], $val, @lst[$idx..$#lst]);
  }
  else {
    return ($val, @lst);
  }
}

sub find_bisect {
  my ($datum, $array) = @_;

  # given 'c' and [a b d e f] returns 2
  # given 'c' and [a b c d e f] returns 2

  # OPTIMIZE
  return (scalar (grep { ($_ cmp $datum) != 1 } @{$array}));
}

1;
