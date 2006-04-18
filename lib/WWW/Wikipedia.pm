package WWW::Wikipedia;

use strict;
use warnings;
use Carp qw( croak );
use CGI qw( escape );
use WWW::Wikipedia::Entry;

use base qw( LWP::UserAgent );

our $VERSION = '1.9';

use constant WIKIPEDIA_URL =>
    'http://%s.wikipedia.org/w/index.php?title=%s&action=raw';

=head1 NAME

WWW::Wikipedia - Automated interface to the Wikipedia 

=head1 SYNOPSIS

  use WWW::Wikipedia;
  my $wiki = WWW::Wikipedia->new();

  ## search for 'perl' 
  my $result = $wiki->search( 'perl' );

  ## if the entry has some text print it out
  if ( $result->text() ) { 
      print $result->text();
  }

  ## list any related items we can look up 
  print join( "\n", $result->related() );

=head1 DESCRIPTION

WWW::Wikipedia provides an automated interface to the Wikipedia 
L<http://www.wikipedia.org>, which is a free, collaborative, online 
encyclopedia. This module allows you to search for a topic and return the 
resulting entry. It also gives you access to related topics which are also 
available via the Wikipedia for that entry.

=head1 METHODS

=head2 new()

The constructor. You can pass it a two letter language code, or nothing
to let it default to 'en'.

    ## Default: English
    my $wiki = WWW::Wikipedia->new();

    ## use the French wiki instead
    my $wiki = WWW::Wikipedia->new( language => 'fr' );

WWW::Wikipedia is a subclass of LWP::UserAgent. If you would
like to have more control over the user agent (control timeouts, proxies ...) 
you have full access.

    ## set HTTP request timeout
    my $wiki = WWW::Wikipedia->new();
    $wiki->timeout( 2 );

=cut

sub new { 
    my ( $class, %opts ) = @_;

    my $language = $opts{ language } || 'en';
    delete $opts{ language };

    my $self = LWP::UserAgent->new( %opts );
    $self->agent( 'WWW::Wikipedia' );
    bless $self, ref($class) || $class;

    $self->language( $language );
    return $self;
}

=head2 language()

This allows you to get and set the language you want to use. Two letter
language codes should be used. The default is 'en'.

    my $wiki = WWW::Wikipedia->new( language => 'es' );
    
    # Later on...
    $wiki->language( 'fr' );

=cut

sub language {
    my( $self, $language) = @_;
    $self->{ language } = $language if $language;
    return $self->{ language };
}

=head2 search() 

Which performs the search and returns a WWW::Wikipedia::Entry object which 
you can query further. See WWW::Wikipedia::Entry docs for more info.

    $entry = $wiki->search( 'Perl' );
    print $entry->text();

If there's a problem connecting to Wikipedia, C<undef> will be returned and the
error message will be stored in C<error()>.

=cut 

sub search {
    my ($self,$string) = @_;

    $self->error( undef );

    croak( "search() requires you pass in a string" ) if ! defined( $string );
    $string = escape( $string );
    my $src = sprintf( WIKIPEDIA_URL, $self->language(), $string );

    my $response = $self->get($src);
    if ( $response->is_success() ) {
	my $entry = WWW::Wikipedia::Entry->new( $response->content(), $src );

        # look for a wikipedia style redirect and process if necessary
        return $self->search($1) if $entry->text() =~ /^#REDIRECT (.*)/;

	return( $entry );
    } else {
	$self->error( "uhoh, WWW::Wikipedia unable to contact " . $src );
	return undef;
    }

}

=head2 error()

This is a generic error accessor/mutator. You can retrieve any searching error
messages here.

=cut

sub error {
    my $self = shift;

    if( @_ ) {
        $self->{ _ERROR } = shift;
    }

    return $self->{ _ERROR };
}

=head1 TODO

=over 4

=item * Clean up results. Strip HTML.

=item * Watch the development of Special:Export XML formatting, eg: http://en.wikipedia.org/wiki/Special:Export/perl

=back

=head1 SEE ALSO

=over 4

=item * LWP::UserAgent

=back

=head1 AUTHORS

=over 4

=item * Ed Summers, E<lt>ehs@pobox.comE<gt>

=item * Brian Cassidy, E<lt>bricas@cpan.orgE<gt>

=back

=head1 COPYRIGHT AND LICENSE

Copyright 2005 by Ed Summers

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;
