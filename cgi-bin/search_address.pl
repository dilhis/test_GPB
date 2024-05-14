#!/usr/bin/perl -w
print "Content-type:text/html; charset=utf-8\r\n\r\n";
use strict;
use warnings;
use DBI;
use CGI;
use CGI::Carp('fatalsToBrowser');

use lib "../lib/";
use Message qw(get_dbh get_count_by_email get_by_email);


my ($buffer, $name, $value, $pair, $email, $row);
my %input;

my $sth;

my $dbh = get_dbh();

if ($ENV{'REQUEST_METHOD'} eq 'POST') {
 read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
 } else {
 $buffer = $ENV{'QUERY_STRING'};
 }
 my @pairs = split(/&/, $buffer);
 foreach $pair (@pairs) {
 ($name, $value) = split(/=/, $pair);
 $value =~ tr/+/ /;
 $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack('C', hex($1))/eg;
 $value =~ s/<!--(.|
 )*-->//g;
 $input{$name} = $value;
 }
$email = $input{'email'};
my $count = get_count_by_email($dbh,$email);
if ($count != 0){
	print qq {
			<table>
			<tbody>
			<div>
				<p>Всего записей с адресом <i><b>$email</b></i> $count</p>
				<a href="/index.html"> Проверить другой адрес </a>
			</div>
			<tr><th>Created</th>
				<th>Message</th>
			</tr>
		};
	my @ret = get_by_email($dbh,$email);
		
		foreach $row (@ret){
			
				print qq {<tr><td>$row->{created}</td>
				<td>$row->{str} </td>
				</tr> 
				};
			
		};	
	

}else{
		print qq {
			<div>
			<p>Записей с адресом <i><b>$email</b></i> не найдено.</p>
		</div>
			};
};
