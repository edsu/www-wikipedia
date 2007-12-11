use strict;
use warnings;

use Test::More tests => 7;

use WWW::Wikipedia;

my ( $wiki, $testexception );

BEGIN {
    eval "use Test::Exception";
    $testexception = $@ ? 0 : 1;
}

# test default language
$wiki = WWW::Wikipedia->new();
isa_ok( $wiki, 'WWW::Wikipedia' );

SKIP: {
    skip 'Test::Exception not installed', 1 unless $testexception;

    throws_ok { $wiki->search(); }
    qr/search\(\) requires you pass in a string/, 'search()';
}

my $entry = $wiki->search( 'perl' );
isa_ok( $entry, 'WWW::Wikipedia::Entry' );
ok( length( $entry->text() ) > 0, 'text()' );

# test language 'es'
$wiki = WWW::Wikipedia->new( language => 'es' );
isa_ok( $wiki, 'WWW::Wikipedia' );

$entry = $wiki->search( 'perl' );
isa_ok( $entry, 'WWW::Wikipedia::Entry' );

ok( length( $entry->fulltext() ) > 0, 'fulltext()' );

