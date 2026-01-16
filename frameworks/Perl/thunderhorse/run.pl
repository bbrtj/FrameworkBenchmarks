#!/usr/bin/env perl

use v5.40;
use Data::Dumper;

my $max_reqs = $ENV{MAX_REQS};
my $test_name = $ENV{TEST_NAME};
my $socket_file = $ENV{SOCKET_FILE};
my $port = $ENV{PROXY_PORT};
my $app_runner = 'app.pl';

my $max_workers = `nproc`;
chomp $max_workers;

my @runner = (
	'pagi-server',
	'--port' => $port,
	'--listener-backlog' => 16384,
	'-E' => 'production',
	'--workers' => $max_workers,
	'--max-requests' => $max_reqs,
	'-a' => $app_runner,
);

# default is mysql (techempower will warn if there is no default)
$test_name = 'thunderhorse-mysql'
	if $test_name eq 'thunderhorse';

die "invalid test name $test_name"
	unless $test_name =~ m{^thunderhorse-(\w+)$};

die 'database mismatch'
	unless $1 eq $ENV{DATABASE};

say 'Running command: ' . Dumper(\@runner);

exec @runner;

