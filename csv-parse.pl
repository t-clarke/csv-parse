#!/usr/bin/perl

# This script will parse a CSV and
# insert the values into a MariaDB
# table. Column names must be
# added manually.

use warnings;
use strict;
use Text::CSV;
use DBI;

# check usage and initialize user
# credentials from cmd-line args as
# well as the name of the CSV from
# which to derive the data
die "usage: parse USERNAME PASSWORD FILE.CSV\n"
	unless @ARGV == 3;
my $uname = $ARGV[0];
my $passwd = $ARGV[1];
my $csv_source = $ARGV[2];

open (my $fd, $csv_source);
my $csv = Text::CSV->new;

# connect to server
my $dbd = DBI->connect('DBI:mysql:##### DB NAME ##### ;host=##### HOSTNAME #####', "$uname", "$passwd")
	or die "Failed to connect to MariaDB";
# create the table
my $sth = $dbd->prepare('create table if not exists ##### TABLE_NAME ##### (
	##### INSERT SQL-y STUFF HERE #####
	 )')
	or die "Failed to prepare SQL query";
$sth->execute();

# trash title line
$csv->getline ($fd);
# prepare a query to insert a column based on
# the current row of data from the CSV file
$sth = $dbd->prepare('insert into ##### TABLE_NAME ##### (
                ##### COLUMN 1 #####
                ##### COLUMN 2 #####
                ##### ETCETERA #####
              	 )
		values
	( ?, ?, ? )') ##### USE AS MANY QUESTION MARKS AS NEEDED #####
        or die "Failed to prepare SQL query";

# loop through and print each row
while (my $line = $csv->getline ($fd)) {
	my @d = @$line;
	print "@d\n";
	$sth->execute($d[0], $d[1], $d[2] ); ##### USE AS MANY ELEMENTS AS YOU HAVE COLUMNS #####
}

close $fd;
$dbd->disconnect;

exit 0;
