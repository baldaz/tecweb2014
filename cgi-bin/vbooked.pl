#!/usr/bin/perl -w

use strict;
use warnings;
#use XML::LibXML;
use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use UTILS;

my $cgi=CGI->new();
my $table='';
my $disciplina=$cgi->param('disciplina');
my $data=$cgi->param('data');

$disciplina='Calcetto' if not defined $disciplina;
$data='2014-04-18' if not defined $data;

my $xml=UTILS::loadXml('../data/prenotazioni.xml');
my $xml_campi=UTILS::loadXml('../data/impianti.xml');

my $nr_campi=UTILS::getFields($xml_campi, $disciplina);
$nr_campi=2 if not defined $nr_campi;
for(1..$nr_campi){
    $table.=UTILS::getWeek($xml, $disciplina, $_, $data);
}
#print "Content-Type: text/html\n\n";
print $cgi->header('text/html;charset=UTF-8');
print $table;
