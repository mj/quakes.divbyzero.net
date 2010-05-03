#!/usr/bin/env perl

#
# Quick & dirty crawler script to feed quake information into the
# data store.
#
#
# apt-get install libxml-rss-perl libclass-dbi-pg-perl
#

use strict;
use XML::RSS;
use LWP::Simple;
use URI::Split qw(uri_split);
use CGI;
use DBI;

my $xml = get("http://geofon.gfz-potsdam.de/db/eqinfo.php?fmt=rss");
my $rss = XML::RSS->new;

my $dbi = DBI->connect("DBI:Pg:dbname=quakes;host=localhost", "quakes", "quakes") or die "Unable to connect: $!";

my $insert = $dbi->prepare("
  INSERT INTO
    quakes (identifier, date, coordinates, magnitude, location, depth, added, url)
  VALUES
    (?, ?, POINT(?, ?), ?, ?, ?, NOW(),?)");

my $search = $dbi->prepare("
  SELECT
    1
  FROM
    quakes
  WHERE
    identifier = ?");

$rss->parse($xml) or die "Unable to parse input: $!";;

foreach my $item (@{$rss->{items}}) {

  my $title = $item->{"title"};
  my $url   = $item->{"link"};
  my $desc  = $item->{"description"};
  
  warn "Unknown title format in " . $url unless $title =~ m/^M (\d+\.\d+), (.+)$/;

  (undef, undef, undef, my $q) = uri_split($url);
  my $cgi = CGI->new($q);
  my $identifier = $cgi->param("id");
  
  my $magnitude = $1;
  my $location  = $2;
  
  warn "Unknown description format in " . $url unless $desc =~ m/^(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\s+(\d+\.\d+) ([NS])\s+(\d+\.\d+) ([EW])\s+(\d+) km/;

  my $date  = $1;
  my $lat   = $2;
  my $lon   = $4;
  my $depth = $6;
  
  $lat = $lat * -1 if $3 eq "S";
  $lon = $lon * -1 if $5 eq "W";

  # There is probably a more efficient way to do this, but for now this
  # will work. Just make sure there is an index on the identifier column.
  $search->execute($identifier);
  next if $search->rows > 0;
    
  $insert->execute((
    $identifier,
    $date,
    $lat,
    $lon,
    $magnitude,
    $location,
    $depth,
    $url,
    ));
}
