use Test::More tests => 2;
use WWW::Wikipedia;

# test to make sure redirects in content are followed
# the use of 'Systems Theory' over time may need to change

$wiki = WWW::Wikipedia->new();
$entry = $wiki->search( 'Systems Theory' );
isa_ok $entry, 'WWW::Wikipedia::Entry';
unlike $entry->text(), qr/REDIRECT/, 'redirect not found';
