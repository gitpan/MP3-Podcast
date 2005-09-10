package MP3::Podcast;

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

MP3::Podcast - Perl extension for podcasting directories full of MP3 files

=head1 SYNOPSIS

  use MP3::Podcast;
  my $dirbase = shift;
  my $urlbase = shift;
  my $dir = shift;
  my $pod = MP3::Podcast->new($dirbase,$urlbase);
  my $rss = $pod->podcast( $dir, "This is a test" );
  print $rss->as_string;

=head1 ABSTRACT

  Create podcast easily from directories, using MP3's own info.

=head1 DESCRIPTION

  Creates a podcast, basically a RSS feed for a directory full of MP3 files.
  Takes information from the MP3 files themselves; it needs MP3 files with 
  their ID tags completed.

  The bundle includes two programs in the C<examples> dir: C<gen-podcast.pl>, 
  used this way:
  bash% ./gen-podcast.pl <dirbase> <urlbase> <dir to scan>
  that generates a static RSS from a dir, and C<podcast.cgi>, to use from a
  webserver. To use it, copy podcast.cgi and podcast.conf to a cgi-serviceable
  dir; edit podcast.conf to your liking and copy it to the directory you want.
  Copy also .podcast to the directory you want served as a podcast (this is done
  mainly to avoid dir-creeping), and also drop
  edit also the path to fetch the  MP3::Podcast lib, and call it with 
  C<http://my.host.com/cgi-bin/podcast.cgi/<dirname>.rss
  The name of the directory to scan will be taken from the URI

=head1 METHODS

=cut

use 5.008;
use strict;
use warnings;

use XML::RSS;
use URI;
use MP3::Info;

our $VERSION = '0.03';

# Preloaded methods go here.

=item new

  Creates the object. Takes basic info as input

=cut

sub new {
  my $class = shift;
  my $dirbase = shift;
  my $urlbase = shift;
  my $self = { dirbase => $dirbase,
	       urlbase => $urlbase };
  bless $self, $class;
  return $self;
}

=item podcast

  Creates the podcast for a dir, that is, an RSS file with enclosures 
  containing the MP3s it can find in that dir. Information to fill RSS 
  fields is contained in the ID3 fields of the MP3 files.
  Returns an XML::RSS object, which you can manipulate, if you feel 
  like doing so
  
=cut

sub podcast {
  my $self = shift;
  my $dir = shift || die "Can't find dir\n";
  my $title = shift || die "Can't find podcast title\n";
  my $creator = shift || 'PerlPodder';
  my $description = shift || $title;
  my $rss = XML::RSS->new( version => '2.0',
			   encoding=> 'iso-8859-1' );
  my $urlbase = $self->{'urlbase'};
  my $dirbase = $self->{'dirbase'};
  
  $rss->channel(title => $title,
                link => "$urlbase/$dir",
                publisher => $creator,
		description => $description );
  
  my $poddir="$dirbase/$dir";
  my $podurl="$urlbase/$dir";
  
  #Leer el directorio
  opendir(D, "$poddir") || die "No se puede abrir directorio $poddir: $!\n";
  while ( my $file = readdir(D) ) {
    next if $file !~ /\.mp3$/i;
    my $filePath="$poddir/$file";
    my @stat = stat($filePath);
    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($stat[9]);
    my $tag = get_mp3tag($filePath) or die "No TAG info for $filePath";
    my ($mp3title) = ( $file =~ /^(.+?)\.mp3/i );
    my $uri = URI->new("$podurl/$file");
    $rss->add_item( title => $tag->{'TITLE'} || $mp3title,
		    link  => $uri,
		    enclosure => { url => $uri,
				   size => $tag->{'SIZE'},
                                   length => $stat[7],
				   type => 'audio/mpeg' },
		    pubDate => ($year+1900)."-$mon-$mday"."T"."$hour:$min:$sec",
		    description => "$tag->{COMMENT}"
		  );
  } 
    return $rss;
}

'All\'s well that ends well';

=head1 SEE ALSO

Info on podcasting: 
Podcast in perl: http://escripting.com/podcast/
Podcastamatic: http://bradley.chicago.il.us/projects/podcastamatic/readme.html
Examples in the C<examples> dir.

=head1 AUTHOR

Juan Julian Merelo Guervos, E<lt>jmerelo@geneura.ugr.esE<gt>. Thanks
to Juan Schwidth E<lt>juan@schwindt.orgE<gt> for patches, suggestion
and encouragement. 

=head1 COPYRIGHT AND LICENSE

  Copyright 2005 by Juan Julian Merelo Guervos

  This library is free software; you can redistribute it and or modify
  it under the same terms as Perl itself. 

=cut
