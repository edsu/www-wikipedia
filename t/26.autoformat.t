use Test::More qw( no_plan );
use WWW::Wikipedia;
use strict;

# Text::Autoformat has had some bugs which some wikipedia content 
# has been known to trigger. Make sure we cover those bases.

my $wiki = WWW::Wikipedia->new();
foreach my $search ( 'princeton', 'Eddie Fenech Adami' ) 
{
    my $entry = $wiki->search($search);
    isa_ok( $entry, 'WWW::Wikipedia::Entry', "search result for: $search" );
}
