#!/usr/bin/perl -w

use strict;
use warnings;
use HTML::Template;
#use XML::LibXML;
use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use UTILS;

my $page=CGI->new();
my ($nr_campi, $table, $data, $disciplina, $xml, $xml_campi, @loop_news);
my $template=HTML::Template->new(filename=>'prenotazioni.tmpl');

$xml=UTILS::loadXml('../data/prenotazioni.xml');
$xml_campi=UTILS::loadXml('../data/impianti.xml');

@loop_news=UTILS::getNews($xml);

$disciplina=$page->param('disciplina');

$data=$page->param('data');
$data='2014-04-18' if not defined $data;
$data='2014-04-18' if $data eq '';

$template->param(NEWS=>\@loop_news);

if(defined($disciplina)){
    $nr_campi=UTILS::getFields($xml_campi, $disciplina);
    $nr_campi=2 if not defined $nr_campi;
    for(1..$nr_campi){
	$table.=UTILS::getWeek($xml, $disciplina, $_, $data);
    }
    $template->param(TABLE=>$table);
}
print "Content-Type: text/html\n\n", $template->output;
