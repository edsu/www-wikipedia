package WWW::Wikipedia::Entry;

use strict;
use warnings;
use Text::Autoformat;
use WWW::Wikipedia;

=head1 NAME

WWW::Wikipedia::Entry - A class for representing a Wikipedia Entry

=head1 SYNOPSIS

    my $wiki = WWW::Wikipedia->new();
    my $entry = $wiki->search( 'Perl' );
    print $entry->text();

    my $entry_es = $entry->language( 'es' );
    print $entry_es->text();

=head1 DESCRIPTION

WWW::Wikipedia::Entry objects are usually created using the search() method
on a WWW::Wikipedia object to search for a term. Once you've got an entry
object you can then extract pieces of information from the entry using 
the following methods.

=head1 METHODS

=head2 new()

You probably won't use this one, it's the constructor that is called 
behind the scenes with the correct arguments by WWW::Wikipedia::search().

=cut

sub new {
    my ( $class, $raw, $src ) = @_;
    return if length( $raw ) == 0;
    my $self = bless {
        raw         => $raw,
        src         => $src,
        text        => '',
        fulltext    => '',
        cursor      => 0,
        related     => [],
        categories  => [],
        headings    => [],
        languages   => {},
        currentlang => ''
        },
        ref( $class ) || $class;
    $self->_parse();

    # store un-"pretty"-ed version of text
    $self->{ fulltext_basic } = $self->{ fulltext };
    $self->{ text_basic }     = $self->{ text };

    $self->{ fulltext } = _pretty( $self->{ fulltext } );
    $self->{ text }     = _pretty( $self->{ text } );
    return ( $self );
}

=head2 text()

The brief text for the entry. This will provide the first paragraph of 
text; basically everything up to the first heading. Ordinarily this will
be what you want to use. When there doesn't appear to be summary text you 
will be returned the fulltext instead.

If text() returns nothing then you probably are looking at a disambiguation
entry, and should use related() to lookup more specific entries.

=cut

sub text {
    my $self = shift;
    return $self->{ text } if $self->{ text };
    return $self->fulltext();
}

=head2 text_basic()

The same as C<text()>, but not run through Text::Autoformat.

=cut

sub text_basic {
    my $self = shift;
    return $self->{ text_basic } if $self->{ text_basic };
    return $self->fulltext_basic();
}

=head2 fulltext()

Returns the full text for the entry, which can be extensive.

=cut

sub fulltext {
    my $self = shift;
    return $self->{ fulltext };
}

=head2 fulltext_basic()

The same as C<fulltext()>, but not run through Text::Autoformat.

=cut

sub fulltext_basic {
    my $self = shift;
    return $self->{ fulltext_basic };
}


=head2 title()

Returns a title of the entry.

=cut

sub title {
    my $self = shift;
    return $self->{ title };
}

=head2 related()

Returns a list of terms in the wikipedia that are mentioned in the 
entry text.

=cut

sub related {
    return ( @{ shift->{ related } } );
}

=head2 categories()

Returns a list of categories which the entry is part of. So Perl is part
of the Programming languages category.

=cut

sub categories {
    return ( @{ shift->{ categories } } );
}

=head2 headings()

Returns a list of headings used in the entry.

=cut

sub headings {
    return ( @{ shift->{ headings } } );
}

=head2 raw()

Returns the raw wikitext for the entry.

=cut

sub raw {
    my $self = shift;
    return $self->{ raw };
}

=head2 language()

With no parameters, it will return the current language of the entry. By
specifying a two-letter language code, it will return the same entry in that
language, if available.

=cut

sub language {
    my $self = shift;
    my $lang = shift;

    return $self->{ currentlang } unless defined $lang;
    return undef unless exists $self->{ languages }->{ $lang };

    my $wiki = WWW::Wikipedia->new( language => $lang );
    return $wiki->search( $self->{ languages }->{ $lang } );
}

=head2 languages()

Returns an array of two letter language codes denoting the languages in which 
this entry is available.

=cut

sub languages {
    my $self = shift;

    return keys %{ $self->{ languages } };
}

## messy internal routine for barebones parsing of wikitext

sub _parse {
    my $self = shift;
    my $raw  = $self->{ raw };
    my $src  = $self->{ src };

    # Add current language
    my ( $lang )  = ( $src =~ /http:\/\/(..)/ );
    my $title = ( split( /\//, $src ) )[ -1 ];

    if( $title =~ m{\?title=} ) {
        ( $title ) = $src =~ m{\?title=([^\&]+)};
        $title =~ s{_}{ }g;
    }

    $self->{ currentlang } = $lang;
    $self->{ languages }->{ $lang } = $title;
    $self->{ title } = $title;

    for (
        $self->{ cursor } = 0;
        $self->{ cursor } < length( $raw );
        $self->{ cursor }++
        )
    {

        pos( $raw ) = $self->{ cursor };

        ## [[ ... ]]
        if ( $raw =~ /\G\[\[ *(.*?) *\]\]/ ) {
            my $directive = $1;
            $self->{ cursor } += length( $& ) - 1;
            if ( $directive =~ /\:/ ) {
                my ( $type, $text ) = split /:/, $directive;
                if ( lc( $type ) eq 'category' ) {
                    push( @{ $self->{ categories } }, $text );
                }

                # language codes
                if ( length( $type ) == 2 and lc( $type ) eq $type ) {
                    $self->{ languages }->{ $type } = $text;
                }
            }
            elsif ( $directive =~ /\|/ ) {
                my ( $lookup, $name ) = split /\|/, $directive;
                $self->{ fulltext } .= $name;
                push( @{ $self->{ related } }, $lookup ) if $lookup !~ /^#/;
            }
            else {
                $self->{ fulltext } .= $directive;
                push( @{ $self->{ related } }, $directive );
            }
        }

        ## === heading 2 ===
        elsif ( $raw =~ /\G=== *(.*?) *===/ ) {
            ### don't bother storing these headings
            $self->{ fulltext } .= $1;
            $self->{ cursor } += length( $& ) - 1;
            next;
        }

        ## == heading 1 ==
        elsif ( $raw =~ /\G== *(.*?) *==/ ) {
            push( @{ $self->{ headings } }, $1 );
            $self->{ text } = $self->{ fulltext } if !$self->{ seenHeading };
            $self->{ seenHeading } = 1;
            $self->{ fulltext } .= $1;
            $self->{ cursor } += length( $& ) - 1;
            next;
        }

        ## '' italics ''
        elsif ( $raw =~ /\G'' *(.*?) *''/ ) {
            $self->{ fulltext } .= $1;
            $self->{ cursor } += length( $& ) - 1;
            next;
        }

        ## {{ disambig }}
        elsif ( $raw =~ /\G{{ *(.*?) *}}/ ) {
            ## ignore for now
            $self->{ cursor } += length( $& ) - 1;
            next;
        }

        else {
            $self->{ fulltext } .= substr( $raw, $self->{ cursor }, 1 );
        }
    }
}

sub _pretty {
    my $text = shift;

    # Text::Autoformat v1.13 chokes on strings that are one or more "\n"
    return '' if $text =~ m/^\n+$/;
    return autoformat(
        $text,
        {   left    => 0,
            right   => 80,
            justify => 'left',
            all     => 1
        }
    );
}

=head1 AUTHORS

Ed Summers E<lt>ehs@pobox.comE<gt>

Brian Cassidy E<lt>bricas@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003-2013 by Ed Summers

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

1;
