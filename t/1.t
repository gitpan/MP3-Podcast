#!/usr/bin/perl

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';
use lib '../lib';

use Test::More tests => 2;
BEGIN { use_ok('MP3::Podcast') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $pod = MP3::Podcast->new('/home/jmerelo/public_html/muzak','http://geneura.ugr.es/~jmerelo/muzak');
isa_ok( $pod, MP3::Podcast );
