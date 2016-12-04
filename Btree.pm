package Btree;
use strict;
use warnings;

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
    _insert($self, $key, $val);
  }
  else {
    # TODO: find the child node that the datum needs to be inserted into
    ...;
  }
}

sub remove {
  ...;
}

sub search {
  ...;
}

sub to_string {
  ...;
}


##
## Secondary functions, called by the top-level methods with no
## argument checking, etc.
##

sub _insert {
  my ($self, $key, $val) = @_;

  if (scalar @{$self->{keys}} < $MAX_DEGREE) { # room for insert?
    my $bisection = find_bisect($key, $self->{keys});

    my @left = (); my @right = (); my @vleft = (); my @vright = (); # This is some seriously disgusting code...
    if ($bisection) {
      @left   = @{$self->{keys}}[0..$bisection-1];
      @right  = @{$self->{keys}}[$bisection..-1];
      @vleft  = @{$self->{values}}[0..$bisection-1];
      @vright = @{$self->{values}}[$bisection..-1];
    }
    else {
      @left = ();
      @right = @{$self->{keys}};
      @vleft = ();
      @vright = @{$self->{values}};
    }

    $self->{keys}   = [@left, $key, @right];
    $self->{values} = [@vleft, $val, @vright];
  }
  else {
    my $parent = defined $self->{parent} ? $self->{parent} :
      Btree->new(leaf => 0,
		 parent => undef,
		 max_degree => $self->{max_degree});
    $self->{parent} = $parent;	# catch case where we make a new parent

    my $new_node = Btree->new(leaf => $self->{leaf},
			      parent => $parent,
			      max_degree => $self->{max_degree});
  }
}


##
## Okay, now we start with the helper functions
##

sub find_bisect {
  my ($datum, $array) = @_;
  # OPTIMIZE
  return (scalar (grep { ($_ cmp $datum) == -1 } @{$array}));
}

1;
