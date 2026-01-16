package ThunderhorseBench::Controller;

use v5.40;
use Mooish::Base;

extends 'Thunderhorse::Controller';

has extended 'app' => (
	handles => [qw(database)],
);

