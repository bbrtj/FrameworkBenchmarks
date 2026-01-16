use v5.40;
use Test2::V1 -ipP;
use Test2::Thunderhorse;
use HTTP::Request::Common;
use Path::Tiny qw(cwd);

use ThunderhorseBench;

# use mock to avoid the need for DB modules and actual running DB
# (however, we do not test for DB code correctness this way)
package DBMock {
	use v5.40;

	use Mooish::Base;

	sub random_number ($self, $id)
	{
		return {
			id => $id,
			randomNumber => int(rand(10_000) + 1),
		};
	}

	sub fortune ($self)
	{
		return [
			{
				id => 1,
				message => 'フレームワークのベンチマーク',
			},
			{
				id => 2,
				message => '<script>test</script>',
			},
			{
				id => 3,
				message => '&&/\\+?',
			},
		];
	}

	sub update ($self, $id, $random_number)
	{
		return;
	}
};

my $app = ThunderhorseBench->new(path => cwd, database => DBMock->new);
my $world = { randomNumber => match(qr{^\d+$}), id => match(qr{^\d+$}) };

subtest plaintext => sub {
	my $uri = '/plaintext';

	http $app, GET $uri;
	http_header_is 'content-type', 'text/plain; charset=utf-8';
	http_text_is 'Hello, World!';
};

subtest 'json' => sub {
	my $uri = '/json';

	http $app, GET $uri;
	http_header_is 'content-type', 'application/json; charset=utf-8';
	is http->json, { message => 'Hello, World!' }, 'json ok';
};

subtest db => sub {
	my $uri = '/db';

	http $app, GET $uri;
	http_header_is 'content-type', 'application/json; charset=utf-8';
	is http->json, $world, 'json ok';
};

subtest queries => sub {
	my $uri = '/queries';

	http $app, GET $uri;
	note http->text;
	is http->json, [$world], 'default json ok';

	http $app, GET "$uri?queries=3";
	is http->json, [$world, $world, $world], '3 queries json ok';

	http $app, GET "$uri?queries=0";
	is http->json, [$world], '0 queries json ok';
};

subtest update => sub {
	my $uri = '/updates';

	http $app, GET "$uri?queries=0";
	is http->json, [$world], 'json ok';

	http $app, GET "$uri?queries=3";
	is http->json, [$world, $world, $world], '3 queries json ok';
};

subtest fortunes => sub {
	my $uri = '/fortunes';

	http $app, GET $uri;
	http_header_is 'content-type', 'text/html; charset=utf-8';

	like http->text, qr{&lt;script&gt;}, 'script escaped ok';
	like http->text, qr{フレームワークのベンチマーク}, 'unicode chars ok';
	like http->text, qr{Additional fortune added at request time.}, 'dynamic message ok';
};

done_testing;

