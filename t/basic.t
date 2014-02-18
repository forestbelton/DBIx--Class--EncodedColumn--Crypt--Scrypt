use strict;
use warnings;

use Test::More;
use Dir::Self;
use lib File::Spec->catdir(__DIR__, 'lib');
use lib File::Spec->catdir(__DIR__, '..', 'lib');

use_ok('Schema')
    or diag("Failed to load test schema");

Schema->load_classes('Scrypt');

my $schema = Schema->connect('dbi:SQLite:dbname=:memory:');
$schema->deploy({});

my $row1 = $schema->resultset('Scrypt')->create({
    hash => 'test'
});

ok($row1->scrypt_check('test'))
    or diag('Verification failed');

ok(not $row1->scrypt_check('test2'))
    or diag('Verification succeeded for wrong value');

my $row2 = $schema->resultset('Scrypt')->create({
    hash => 'test'
});

ok($row1->hash ne $row2->hash)
    or diag('Hashes not different for two rows with same input');

done_testing();
