use strict;
use warnings;
use Test::More tests => 3;

package WWW::Wikipedia;

use HTTP::Response;

sub get {
    return HTTP::Response->new( 500 );
}

package main;

use WWW::Wikipedia;

# test default language
my $wiki = WWW::Wikipedia->new();
isa_ok( $wiki, 'WWW::Wikipedia' );

my $entry = $wiki->search( 'perl' );
is( $entry, undef, 'search() returns undef' );
like( $wiki->error, qr/^uhoh, WWW::Wikipedia unable to contact/, 'error()' );
