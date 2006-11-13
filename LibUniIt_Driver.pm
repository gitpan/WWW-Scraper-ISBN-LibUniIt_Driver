package WWW::Scraper::ISBN::LibUniIt_Driver;

use strict;
use warnings;
use LWP::UserAgent;
use WWW::Scraper::ISBN::Driver;
use HTML::Entities qw(decode_entities);

our @ISA = qw(WWW::Scraper::ISBN::Driver);

our $VERSION = '0.1';
                
sub search {
        my $self = shift;
        my $isbn = shift;
        $self->found(0);
        $self->book(undef);
	
        my $post_url = "http://www.libreriauniversitaria.it/c_search.php?noinput=1&isbn_query=" . $isbn;
        my $ua = new LWP::UserAgent;
        my $res = $ua->get($post_url);
        my $doc = $res->as_string;
        
        my $title = "";
        my $authors = "";
        my $editor = "";
	my $date = "";
	my $price = "";
        
        unless ($doc =~ /Risultati della ricerca Libri Italiani/) {
	    $self->error("libro non trovato.\n");
	    $self->found(0);
	    return 0;
	}
	
	$title = $1 if ($doc =~ /<a class="btitle" href="[^"]+"\s*>([^<]+)<\/a>/);
	decode_entities($title);	
	if ($doc =~ /Autor[ei]: <em>(.+)<\/em>/) {
	    my $authorslist = $1;
	    my $sep = "";
	    while ($authorslist =~ s/<a href="[^"]+">([^<]+)<\/a>,?//) {
		$authors .=  $sep . $1;
		$sep = ", ";
	    }
	}
	decode_entities($authors);	
	if ($doc =~ /<a href="goto\/publisher_[^"]+">([^<]+)<\/a>, (\d{4})/){
	    $editor = $1;
	    $date = $2;
	}
	decode_entities($editor);	
	$price = $1 if ($doc =~ /&euro;&nbsp;(\d+)/);
        
	my $bk = {   
                'isbn' => $isbn,
                'author' => $authors,
                'title' => $title,
                'editor' => $editor,
		'date' => $date,
		'price' => $price,
        };
	$self->book($bk);
	$self->found(1);
        return $bk;
}

1;
__END__

=head1 NAME

WWW::Scraper::ISBN::LibUniIt - Driver for L<WWW::Scraper::ISBN> that searches L<http://www.libreriauniversitaria.it/>.

=head1 SYNOPSIS

See parent class documentation (L<WWW::Scraper::ISBN::Driver>)

=head1 REQUIRES

Requires the following modules be installed:

=over 4

=item L<WWW::Scraper::ISBN::Driver>

=item L<HTML::Entities>

=item L<LWP::UserAgent>

=back

=head1 DESCRIPTION

Searches for book information from http://www.libreriauniversitaria.it

=head1 METHODS

=over 4

=item C<search()>

Searches for an ISBN on L<http://www.libreriauniversitaria.it/>.
If a valid result is returned the following fields are returned:

   isbn
   author
   title
   editor
   date
   price

=head2 EXPORT

None by default.

=head1 SEE ALSO

=over 4

=item L<< WWW::Scraper::ISBN >>

=item L<< WWW::Scraper::ISBN::Record >>

=item L<< WWW::Scraper::ISBN::Driver >>

=back

=head1 AUTHOR

Angelo Lucia, E<lt>angelo.lucia@email.itE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2006 by Angelo Lucia

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
