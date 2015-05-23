use strict;
use warnings;
use Test::More tests => 3;
use WWW::Wikipedia;

# Text::Autoformat has had some bugs which some wikipedia content
# has been known to trigger. Make sure we cover those bases.

my $wiki = WWW::Wikipedia->new( clean_html => 1 );

my $entry = $wiki->search( 'Inequality_(mathematics)' );
# test some specific constructs that are not likely to be removed
# by wikipedia users. This is dangerous...
like $entry->text, qr/a < b/, "Less than was kept";

$entry = $wiki->search( 'Ampersand' );
unlike $entry->text, qr/<ref/, "Ref Begin tag was removed";
unlike $entry->text, qr/<\/ref/, "Ref End tag was removed";

