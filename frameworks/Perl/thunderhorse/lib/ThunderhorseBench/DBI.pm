package ThunderhorseBench::DBI;

use v5.40;
use Mooish::Base;
use DBI;

# TODO: async db

has field 'dbh' => (
	builder => 1,
);

has field '_world' => (
	lazy => sub ($self) {
		$self->dbh->prepare("SELECT * FROM World WHERE id = ?");
	},
);

has field '_fortune' => (
	lazy => sub ($self) {
		$self->dbh->prepare("SELECT * FROM Fortune");
	},
);

has field '_update' => (
	lazy => sub ($self) {
		$self->dbh->prepare("UPDATE World SET randomNumber = ? WHERE id = ?");
	},
);

sub _build_dbh ($self)
{
	DBI->connect(
		"dbi:MariaDB:database=hello_world;host=tfb-database;port=3306",
		'benchmarkdbuser',
		'benchmarkdbpass',
		{ RaiseError => 1, PrintError => 0 }
	);
}

sub random_number ($self, $id)
{
	$self->_world->execute($id);
	return $self->_world->fetchrow_hashref;
}

sub fortune ($self)
{
	$self->_fortune->execute();
	return $self->_fortune->fetchall_arrayref({});
}

sub update ($self, $id, $random_number)
{
	$self->_update->execute($random_number, $id);
	return;
}

