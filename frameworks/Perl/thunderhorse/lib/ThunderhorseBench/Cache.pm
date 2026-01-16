package ThunderhorseBench::Cache;

use v5.40;
use Mooish::Base;

has field 'memory' => (
	isa => HashRef,
	default => sub { {} },
);

# no need for SpecializedCache here, since we are caching in process memory

sub get ($self, $key)
{
	return $self->memory->{$key};
}

sub set ($self, $key, $value)
{
	$self->memory->{$key} = $value;
}

sub clear ($self)
{
	$self->memory->%* = ();
}

