#!/usr/bin/perl

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use lib '../lib';

use Test::More qw(no_plan);
BEGIN { use_ok('MP3::Podcast') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $pod = MP3::Podcast->new('/home/jmerelo/public_html/muzak','http://geneura.ugr.es/~jmerelo/muzak');
isa_ok( $pod, 'MP3::Podcast' );


print "Please enter a base directory with MP3s to create the podcast, just enter if you want to skip this test\n";
my $dir = <STDIN>;
chop($dir);
exit if !$dir;
$pod = MP3::Podcast->new($dir,'http://this.is/a/url');
print "Please enter a subdir with MP3s to create the podcast, just enter if you want to skip this test\n";
my $subdir = <STDIN>;
chop($subdir);
my $rss =  $pod->podcast($subdir, "Test");
isa_ok( $rss, 'XML::RSS' );
is( $rss->{'items'}->[0]->{title} ne '', 1, "RSS" );


