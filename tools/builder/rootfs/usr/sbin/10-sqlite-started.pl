#!/usr/bin/env perl

use strict;
use warnings;
use feature qw( say );

use DBI;

my $dbfile = '/mnt/geoip/Country-Networks.db';

use DBD::SQLite::Constants qw/:file_open/;

my $dbh = DBI->connect("dbi:SQLite:$dbfile", undef, undef, {
    sqlite_open_flags => SQLITE_OPEN_READONLY,
  });

my $sth = $dbh->prepare(
   'SELECT network FROM IPv4 WHERE country_id = ?'
);
$sth->execute(2921044);

while (my @row = $sth->fetchrow_array) {
   print "network: $row[0]\n";
}

$dbh->disconnect;

say "query done";
