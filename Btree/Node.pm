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
    my $node = _insert_into_leaf($self, $key, $val);
    return $node->_root;
  }
  else {
    # TODO: write more succinctly
    my $chld = $self->_find_leaf($key);
    my $node = _insert_into_leaf($chld, $key, $val);
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

sub _insert_into_leaf {
  my ($node, $key, $val) = @_;

  if (scalar @{$node->{keys}} < $node->{max_degree}) { # room for insert?
    my $bisection = find_bisect($key, $node->{keys});

    my @left = (); my @right = (); my @vleft = (); my @vright = (); # This is some seriously disgusting code...
    if ($bisection) {
      @left   = @{$node->{keys}}[0..$bisection-1];
      @right  = @{$node->{keys}}[$bisection..-1];
      @vleft  = @{$node->{values}}[0..$bisection-1];
      @vright = @{$node->{values}}[$bisection..-1];
    }
    else {
      @left = ();
      @right = @{$node->{keys}};
      @vleft = ();
      @vright = @{$node->{values}};
    }

    $node->{keys}   = [@left, $key, @right];
    $node->{values} = [@vleft, $val, @vright];
    return $node;
  }
  else {			# ok, we need to split
    my $parent = defined $node->{parent} ? $node->{parent} :
      Btree::Node->new(leaf       => 0,
		       parent     => undef,
		       values     => [$node],
		       max_degree => $node->{max_degree});

    $node->{parent} = $parent;	# here we catch the case where we make a new parent

    my $new_node = Btree::Node->new(leaf       => $node->{leaf},
				    parent     => $parent,
				    max_degree => $node->{max_degree});
    $new_node->{next_leaf} = $node->{next_leaf};
    $node->{next_leaf} = $new_node;

    my $half_way = int $new_node->{max_degree} / 2;
    $new_node->{keys} = [splice @{$node->{keys}}, $half_way];
    $half_way++ unless $node->{leaf};
    $new_node->{values} = [splice @{$node->{values}}, $half_way];

    $parent->_insert_into_branch($new_node->{keys}->[0], $new_node);
    $parent->insert($key, $val);
    return $parent;
  }
}

sub _insert_into_branch {
  my ($node, $key, $value) = @_;
  my $first_value = shift @{$node->{values}};
  $node->_insert_into_leaf($key, $value);
  unshift @{$node->{values}}, $first_value;
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

sub find_bisect {
  my ($datum, $array) = @_;

  # given 'c' and [a b d e f] returns 2
  # given 'c' and [a b c d e f] returns 2

  # OPTIMIZE
  return (scalar (grep { ($_ cmp $datum) == -1 } @{$array}));
}

1;
