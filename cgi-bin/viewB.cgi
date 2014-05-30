#!/usr/bin/perl -w

use strict;
use warnings;
use HTML::Template;
use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use UTILS;

$ENV{HTML_TEMPLATE_ROOT} = "../public_html/templates";
my $page = CGI->new();
my $is_logged = 0;
#my $session=CGI::Session->new($cgi);
my $session = CGI::Session->load();
if($session->param("~logged-in")){
	$is_logged = 1;
}
my ($nr_campi, $table, $data, $disciplina, $xml, $xml_campi, $today, @loop_news, @discipline);
my $template = HTML::Template->new(filename=>'prenotazioni.tmpl');
$template->param(page => 'viewB.cgi');
$template->param(path => 'Prenotazioni');
$template->param(LOGIN => $is_logged);
$template->param(USER => 'Admin');

$xml = UTILS::loadXml('../data/prenotazioni.xml');
$xml_campi = UTILS::loadXml('../data/impianti.xml');

@loop_news = UTILS::getNews($xml);

@discipline = ('Calcetto', 'Calciotto', 'Pallavolo', 'Beach Volley', 'Tennis'); 
$disciplina = $page->param('disciplina');

$disciplina = $discipline[0] unless grep { $_ eq $disciplina } @discipline; # sanity check

$today = UTILS::_today;
$data = $page->param('data') || $today;
$data = $today if $data eq '';

$template->param(NEWS => \@loop_news);

if(defined($disciplina)){
    $nr_campi = UTILS::getFields($xml_campi, $disciplina);
    $nr_campi = 2 if not defined $nr_campi;
    for(1..$nr_campi){
	$table.= UTILS::getWeek($xml, $disciplina, $_, $data);
    }
    $template->param(TABLE => $table);
}
print "Content-Type: text/html\n\n", $template->output;
