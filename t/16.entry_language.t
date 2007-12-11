use strict;
use warnings;
use Test::More tests => 7;

use_ok( 'WWW::Wikipedia::Entry' );

my $wikitext = getWikiText( 'perl.raw' );

my $entry = WWW::Wikipedia::Entry->new( $wikitext,
    'http://en.wikipedia.org/wiki/Perl' );
isa_ok( $entry, 'WWW::Wikipedia::Entry' );

is( $entry->languages(), 15,   'languages()' );
is( $entry->language(),  'en', 'language()' );

my $entry_es = $entry->language( 'es' );
isa_ok( $entry_es, 'WWW::Wikipedia::Entry' );

ok( $entry_es->languages() > 0, 'languages()' );
is( $entry_es->language(), 'es', 'language()' );

## fetches some wikitext from disk
sub getWikiText {
    my $file = shift;
    open( TEXT, "t/$file" );
    my $text = join( '', <TEXT> );
    close( TEXT );
    return ( $text );
}

