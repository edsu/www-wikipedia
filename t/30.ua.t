use strict;
use warnings;
use Test::More tests => 2;

use_ok( 'WWW::Wikipedia' );

my $wiki = WWW::Wikipedia->new();
isa_ok( $wiki, 'LWP::UserAgent' );

