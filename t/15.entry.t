use strict;
use warnings;
use Test::More tests => 16;

use_ok( 'WWW::Wikipedia::Entry' );

## test english text

my $wikitext = getWikiText( 'perl.raw' );

my $entry = WWW::Wikipedia::Entry->new( $wikitext,
    'http://en.wikipedia.org/wiki/Perl' );
isa_ok( $entry, 'WWW::Wikipedia::Entry' );

my $text = $entry->text();
like( $text, qr/'Perl', also 'Practical Extraction and Report Language'/,
    'text()' );
ok( $entry->text_basic(), 'text_basic()' );

is( $entry->headings(), 13, 'headings()' );

my @categories = $entry->categories();
is( $categories[ 0 ], "Programming languages", 'categories()' );

is( $entry->related(), 91, 'related()' );
is( $entry->raw(), $wikitext, 'raw()' );
is( $entry->title(), 'Perl', 'title()' );

## test spanish text
$wikitext = getWikiText( 'perl.es.raw' );
$entry    = WWW::Wikipedia::Entry->new( $wikitext,
    'http://es.wikipedia.org/wiki/Perl' );
isa_ok( $entry, 'WWW::Wikipedia::Entry' );
ok( $entry->text(), 'text()' );
is( $entry->headings(), 0, 'headings()' );
@categories = $entry->categories();
is( $categories[ 0 ],  "Lenguajes interpretados", 'categories()' );
is( $entry->related(), 36,                        'related()' );
is( $entry->raw(),     $wikitext,                 'raw()' );
is( $entry->title(), 'Perl', 'title()' );

## fetches some wikitext from disk
sub getWikiText {
    my $file = shift;
    open( TEXT, "t/$file" );
    my $text = join( '', <TEXT> );
    close( TEXT );
    return ( $text );
}

