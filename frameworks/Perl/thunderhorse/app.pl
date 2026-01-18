#!/usr/bin/env perl

use Path::Tiny qw(path);
use lib path(__FILE__)->parent->child('lib');
use ThunderhorseBench;

use Future::AsyncAwait;
use PAGI::Request;
use PAGI::Response;
use v5.40;

# ThunderhorseBench->new->run;
async sub ($scope, $receive, $send) {
	return unless $scope->{type} eq 'http';
	# my $req = PAGI::Request->new($scope, $receive, $send);
	my $res = PAGI::Response->new($scope, $send);
	await $res->json({ message => 'Hello, World!' });
	return;
}

