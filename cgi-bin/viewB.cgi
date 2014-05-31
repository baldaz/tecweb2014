#!/usr/bin/perl -w

use strict;
use warnings;
use HTML::Template;
use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use UTILS;

$ENV{HTML_TEMPLATE_ROOT} = "../public_html/templates";

my $page = CGI->new();
my $is_logged = UTILS::is_logged;
my ($nr_campi, $table, $data, $disciplina, $xml, $xml_campi, $today, @discipline);

$xml = UTILS::loadXml('../data/prenotazioni.xml');
$xml_campi = UTILS::loadXml('../data/impianti.xml');

@discipline = ('Calcetto', 'Calciotto', 'Pallavolo', 'Beach Volley', 'Tennis'); 
$disciplina = $page->param('disciplina');

$disciplina = $discipline[0] unless grep { $_ eq $disciplina } @discipline; # sanity check

$today = UTILS::_today;
$data = $page->param('data') || $today;
$data = $today if $data eq '';

$nr_campi = UTILS::getFields($xml_campi, $disciplina);
$nr_campi = 2 if not defined $nr_campi;
for(1..$nr_campi){
    $table.= UTILS::getWeek($xml, $disciplina, $_, $data);
}

my %params = (
    page  => 'viewB.cgi',
    path  => 'Prenotazioni',
    LOGIN => $is_logged,
    USER  => 'Admin',
    TABLE => $table
    );

UTILS::dispatcher('prenotazioni', %params);
