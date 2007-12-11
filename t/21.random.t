use strict;
use warnings;
use Test::More tests => 4;

use WWW::Wikipedia;

# test default language
my $wiki = WWW::Wikipedia->new();
isa_ok( $wiki, 'WWW::Wikipedia' );

my $entry = $wiki->random();
isa_ok( $entry, 'WWW::Wikipedia::Entry' );
ok( length( $entry->text() ) > 0,     'text()' );
ok( length( $entry->fulltext() ) > 0, 'fulltext()' );

