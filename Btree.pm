package Btree;
use strict;
use warnings;

use Btree::Node;

our $MAX_DEGREE = 3;

$Btree::Node::MAX_DEGREE = $MAX_DEGREE;

sub new {
  my $class = shift;

  my %args = (
	      max_degree => $MAX_DEGREE,
	      @_,
	     );
  $args{head_node} = Btree::Node->new(max_degree => $args{max_degree});

  return bless \%args, $class;
}

sub insert {
  my $self = shift;
  $self->{head_node} = $self->{head_node}->insert(@_);
}

sub remove {
  ...;
}

sub search {
  # use the _find_child() function
  ...;
}

sub to_string {
  my $self = shift;
  return $self->{head_node}->to_string();
}

sub to_hash {
    my $self = shift;
    return $self->{head_node}->to_hash;
}

1;
