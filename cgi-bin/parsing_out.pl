#!/usr/bin/perl -w 
print "Content-Type: text/html\n\n";
use Data::Dumper;
use warnings;
use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser);
use strict;
use DBI;
use lib "../lib/";
use Message qw(get_dbh);

my @data, ;

# Подключаемся к БД
my ($date, $time, $int_id, $f, $address, $str, $id, $created);

my $sth;

my $dbh = get_dbh();
# создаем файловый дескриптор
open FID, "out"
  or die "Failed to open out: $!\n";
push @data, $_ while(<FID>);
close FID; # закрываем файловый дескриптор


foreach my $st (@data) {
    ($date, $time, $int_id, $f, $address)= split (' ', $st);
	 $created = $date . " " . $time;
	 substr($st, 0, 20) = "";
	 $str = $st;
	 

	if ($f eq '<=') { #insert in message table
		
		if ($st =~ m#id=(\S+)\s+#) {
			$id = $1;
			$sth = $dbh->prepare("
			INSERT INTO 
				message(created,id,int_id,str,status) 
			VALUES
				(?,?,?,?,?)");
			$sth->execute($created,$id,$int_id,$str,1) or die $DBI::errstr;

		} else {
			$sth = $dbh->prepare("
			INSERT INTO 
				log(created,int_id,str,address) 
			VALUES
				(?,?,?,?)");
			$sth->execute($created,$int_id,$str,$address) or die $DBI::errstr;
		};

	} else { #insert in log table
	
		$sth = $dbh->prepare("
		INSERT INTO 
				log(created,int_id,str,address) 
		VALUES
			(?,?,?,?)");
		$sth->execute($created,$int_id,$str,$address) or die $DBI::errstr;

	}	
}
$sth->finish();

