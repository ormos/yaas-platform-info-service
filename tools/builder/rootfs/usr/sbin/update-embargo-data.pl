#!/usr/bin/env perl

use strict;
use warnings;
use feature qw( say );

use DBI;
use DBD::SQLite::Constants qw/:file_open/;

use JSON;

use MaxMind::DB::Writer::Tree;
use Net::Works::Network;

my $mmdbfile = '/mnt/geoip/Embargo-Networks.mmdb';
my $dbfile = '/mnt/geoip/Country-Networks.db';
my $jsonfile = '/mnt/geoip/access.json';

my %types = (
    country  => 'utf8_string',
    from     => 'uint32',
    until    => 'uint32',
);

my %data_info = (
    country  => 'Germany',
    from     => 0,
    until    => 0,
);

my $json_data = do {
    local $/;
    open my $fhj, '<', $jsonfile;
    <$fhj>
};
my $json_doc = decode_json($json_data);

say "$json_doc->{'blocked'}->[1]->{'id'}";

my $tree = MaxMind::DB::Writer::Tree->new(

    # "database_type" is some arbitrary string describing the database.  At
    # MaxMind we use strings like 'GeoIP2-City', 'GeoIP2-Country', etc.
    database_type => 'Embargo-Networks',

    # "description" is a hashref where the keys are language names and the
    # values are descriptions of the database in that language.
    description =>
        { en => 'Public IP networks of countries under embargo', },

    # "ip_version" can be either 4 or 6
    ip_version => 4,

    # add a callback to validate data going in to the database
    map_key_type_callback => sub { $types{ $_[0] } },

    # "record_size" is the record size in bits.  Either 24, 28 or 32.
    record_size => 24,
);

my $dbh = DBI->connect("dbi:SQLite:$dbfile", undef, undef, {
    sqlite_open_flags => SQLITE_OPEN_READONLY,
  });

my $sth = $dbh->prepare(
   'SELECT network FROM IPv4 WHERE country_id = ?'
);

$sth->execute(2921044);

while (my @row = $sth->fetchrow_array) {

    my $network = Net::Works::Network->new_from_string( string => $row[0] );

    $tree->insert_network( $network, \%data_info );
}

$dbh->disconnect;

# Write the database to disk.
open my $fh, '>:raw', $mmdbfile;
$tree->write_tree( $fh );
close $fh;

say "$mmdbfile has now been created";
