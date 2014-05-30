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

my $xml=UTILS::loadXml('../data/prenotazioni.xml');
my $xml_campi=UTILS::loadXml('../data/impianti.xml');

my $nr_campi=UTILS::getFields($xml_campi, $disciplina);
$nr_campi=2 if not defined $nr_campi;
for(1..$nr_campi){
    $table.=UTILS::getWeek($xml, $disciplina, $_, $data);
}
print $cgi->header('text/plain;charset=UTF-8'), $table;
