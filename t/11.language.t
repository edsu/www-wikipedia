use strict;
use warnings;

use Test::More tests => 7;

use WWW::Wikipedia;

my $wiki;

# test default language: 'en'
$wiki = WWW::Wikipedia->new();
isa_ok( $wiki, 'WWW::Wikipedia' );
is( $wiki->language, 'en', 'default language' );

# test language on new()
$wiki = WWW::Wikipedia->new( language => 'es' );
isa_ok( $wiki, 'WWW::Wikipedia' );
is( $wiki->language, 'es', "new( language => 'es' )" );

# test language switching after new()
$wiki = WWW::Wikipedia->new();
isa_ok( $wiki, 'WWW::Wikipedia' );
is( $wiki->language, 'en', 'default language' );
$wiki->language( 'fr' );
is( $wiki->language, 'fr', "language( 'fr' )" );
