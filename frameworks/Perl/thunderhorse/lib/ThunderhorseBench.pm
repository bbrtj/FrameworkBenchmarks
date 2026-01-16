package ThunderhorseBench;

use v5.40;
use Mooish::Base;

use ThunderhorseBench::Cache;

extends 'Thunderhorse::App';

## Attributes

has param 'database' => (
	builder => 1,
);

sub _build_database ($self)
{
	if (lc $ENV{DATABASE} eq 'mysql') {
		require ThunderhorseBench::DBI;
		return ThunderhorseBench::DBI->new;
	}
	else {
		die "unknown database chosen: $ENV{DATABASE}";
	}
}

sub build ($self)
{
	$self->router->set_cache(ThunderhorseBench::Cache->new);

	$self->load_module('Template', {
		paths => [$self->path->child('views')->stringify],
		conf => {
			STRICT => 1,
			OUTLINE_TAG => qr{\V*%%}, # https://github.com/abw/Template2/issues/320
		},
	});

	$self->load_controller('Base');
}

