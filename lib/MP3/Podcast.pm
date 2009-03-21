package MP3::Podcast;

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
which generates a static RSS from a dir, and C<podcast.cgi>, to use from a
webserver. To use it, copy C<podcast.cgi> and C<podcast.conf> to a cgi-serviceable
dir; edit C<podcast.conf> to your liking and copy it to the directory you want.
Copy also C<.podcast> to the directory you want served as a podcast
(this is done mainly to avoid dir-creeping),
edit  the path to fetch the  MP3::Podcast lib, and call it with 
C<http://my.host.com/cgi-bin/podcast.cgi/[dirname].rss>
The name of the directory to scan will be taken from the URI

This new version includes in the test directory MP3s by the Spanish
    group L<Anima Adversa|http://animaadversa.es>, which are freely
    distributed under a CC license.

=head1 METHODS

=cut

use 5.008;
use strict;
use warnings;

use XML::RSS;
use URI;
use MP3::Info;
use POSIX qw(strftime);

our $VERSION = '0.06_1aa';

# Preloaded methods go here.

=item new

Creates the object. Takes basic info as input: the address of the
    directory that will
be scanned, the base URL that will be used to podcast this URL base.

=cut

sub new {
  my $class = shift;
  my $dirbase = shift || die "Need a base dir\n";
  my $urlbase = shift || die "Need a base URL\n";
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
like doing so.
  
=cut

sub podcast {
  my $self = shift;
  my $dir = shift || die "Can't find dir\n";
  my $title = shift || die "Can't find podcast title\n";
  my $creator = shift || "MP3::Podcast $VERSION";
  my $description = shift || $title;
  my $sort = shift; 
  my $rss = XML::RSS->new( version => '2.0',
                           encoding=> 'UTF-8' );
  my $urlbase = $self->{'urlbase'};
  my $dirbase = $self->{'dirbase'};
  
  $rss->channel(title => $title,
                link => "$urlbase/$dir",
                publisher => $creator,
                description => $description );
  
  my $poddir="$dirbase/$dir";
  my $podurl="$urlbase/$dir";
  
  #Read directory
  opendir(D, "$poddir") || die "Couldn't open directory $poddir: $!\n";
  my @files = readdir(D);
  closedir(D) || die "Couldn't close dir $poddir\n";
  if ( $sort ) {
        @files = reverse(sort(@files));
  } 
  foreach my $file ( @files ) {
    next if $file !~ /\.[Mm][Pp]3$/i;
    my $filePath="$poddir/$file";
    my @stat = stat($filePath);
    my $pubdate = strftime("%a, %e %b %Y %T %z", localtime($stat[9]));
    my $tag = get_mp3tag($filePath) or die "No TAG info for $filePath";
    my ($mp3title) = ( $file =~ /^(.+?)\.mp3/i );
    my $uri = URI->new("$podurl/$file");
    $rss->add_item( title => $tag->{'TITLE'} || $mp3title,
                    link  => $uri,
                    enclosure => { url => $uri,
                                   length => $stat[7],
                                   type => 'audio/mpeg' },
                    pubDate => $pubdate,
                    description => "Podcast $tag->{COMMENT}" );
  } 
  return $rss;

}

'All\'s well that ends well';

=head1 SEE ALSO

Info on podcasting:

=over 4

=item Podcast in perl: http://escripting.com/podcast/

=item Podcastamatic: http://bradley.chicago.il.us/projects/podcastamatic/readme.html

=item Examples in the C<examples> dir.

=back


=head1 AUTHOR

Juan Julian Merelo Guervos, E<lt>jmerelo {at} geneura.ugr.esE<gt>. Thanks
to Juan Schwindt E<lt>juan {at} schwindt.orgE<gt>, Matt Domsch
E<lt>matt {at} domsch.comE<gt>, Gavin Hurlbut E<lt>gjhurlbu {at}
gmail.comE<gt>  and Eric Johnson E<lt>eric {at} el-studio.com E<gt>
    for patches, suggestion and encouragement.

=head1 COPYRIGHT AND LICENSE

Copyright 2005-2009 by Juan Julian Merelo Guervos

This library is free software; you can redistribute it and or modify
it under the same terms as Perl itself.

=cut
