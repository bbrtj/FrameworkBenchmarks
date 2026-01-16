package ThunderhorseBench::Controller::Base;

use v5.40;
use Mooish::Base;

extends 'ThunderhorseBench::Controller';

## Utilities

sub validate_number ($self, $num, $min, $max)
{
	return $min unless length($num // '') && $num !~ /\D/;
	return $min if $num < $min;
	return $max if $num > $max;
	return $num;
}

sub random_number ($self, $max = 10_000)
{
	return int(rand($max) + 1);
}

sub random_id ($self)
{
	# in case random ids were not the same as random numbers
	return $self->random_number(10_000);
}

sub get_random_entries ($self, $count)
{
	$count = $self->validate_number($count, 1, 500);

	my @result;
	for (1 .. $count) {
		my $id = $self->random_id;
		my $row = $self->database->random_number($id);
		next unless $row;

		push @result, {
			id => $id,
			randomNumber => $row->{randomNumber}
		};
	}

	return \@result;
}

## Framework code

sub build ($self)
{
	my $router = $self->router;
	$router->add('/plaintext' => { action => 'http.get', to => 'handle_plaintext' });
	$router->add('/json' => { action => 'http.get', to => 'handle_json' });
	$router->add('/db' => { action => 'http.get', to => 'handle_db' });
	$router->add('/queries' => { action => 'http.get', to => 'handle_queries' });
	$router->add('/fortunes' => { action => 'http.get', to => 'handle_fortunes' });
	$router->add('/updates' => { action => 'http.get', to => 'handle_updates' });
}

sub handle_plaintext ($self, $ctx)
{
	return $ctx->res->text('Hello, World!');
}

sub handle_json ($self, $ctx)
{
	return $ctx->res->json({ message => 'Hello, World!' });
}

sub handle_db ($self, $ctx)
{
	my $id = $self->random_id;
	my $row = $self->database->random_number($id);

	return $ctx->res->json({ id => $id, randomNumber => $row->{randomNumber} });
}

sub handle_queries ($self, $ctx)
{
	return $ctx->res->json(
		$self->get_random_entries($ctx->req->query('queries'))
	);
}

sub handle_fortunes ($self, $ctx)
{
	my $objects = $self->database->fortune;

	push $objects->@*, {
		id => 0,
		message => "Additional fortune added at request time."
	};

	$objects->@* = sort { $a->{message} cmp $b->{message} } $objects->@*;
	return $self->template('fortunes', { rows => $objects });
}

sub handle_updates ($self, $ctx)
{
	my $arr = $self->get_random_entries($ctx->req->query('queries'));

	foreach my $row ($arr->@*) {
		$row->{randomNumber} = $self->random_number;
		$self->database->update($row->@{qw(id randomNumber)});
	}

	return $ctx->res->json($arr);
}

