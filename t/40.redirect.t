use strict;
use warnings;

use Test::More tests => 4;
use WWW::Wikipedia;

# the use of 'Systems Theory' over time may need to change
my $q    = 'Systems Theory';
my $wiki = WWW::Wikipedia->new();

# test to make sure redirects in content are followed
{
    my $entry = $wiki->search( $q );
    isa_ok $entry, 'WWW::Wikipedia::Entry';
    unlike $entry->text(), qr/REDIRECT/, 'redirect not found';
}

# test to make sure redirects in content are not followed
# when follow_redirects == 0
{
    $wiki->follow_redirects( 0 );
    my $entry = $wiki->search( $q );
    isa_ok $entry, 'WWW::Wikipedia::Entry';
    like $entry->text(), qr/REDIRECT/, 'redirect found';
}
