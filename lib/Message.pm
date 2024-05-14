#!/usr/bin/perl

package Message ;

use utf8;
use warnings;
use Exporter;

use DBI;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(get_dbh get_count_by_email get_by_email);


sub get_dbh {
	my $dsn = "DBI:mysql:dilhis";
my $username = "dilhis";
my $password = '12345';
my $dbh  = DBI->connect($dsn,$username,$password) or
die("Ошибка подключения к базе данных: $DBI::errstr\n");

	return $dbh;
}

sub get_count_by_email {
	my ($dbh, $email) = @_;
	my $count = $dbh->selectrow_array("SELECT count(*) FROM
	(SELECT `created`, `int_id`, `str` FROM `log` WHERE `address` = '$email'
	UNION SELECT `created`, `int_id`, `str` FROM `message` WHERE `str` LIKE '%str%'
	)
	AS `a` ORDER BY `int_id`, `created`")
        or die $DBI::errstr;

	return $count;
};

sub get_by_email {
	my ($dbh, $email) = @_;


	$sth = $dbh->prepare("SELECT `created`, `str` FROM
	(SELECT `created`, `int_id`, `str` FROM `log` WHERE `address` = '$email'
	UNION SELECT `created`, `int_id`, `str` FROM `message` WHERE `str` LIKE '%str%'
	)
	AS `a` ORDER BY `int_id`, `created` LIMIT 100");
	$sth->execute() or die $DBI::errstr;
	my @ret;
		while ( my $row = $sth->fetchrow_hashref ) {
			push @ret, $row;

		}
	return @ret;
};
1;