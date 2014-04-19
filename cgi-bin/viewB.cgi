#!/usr/bin/perl -w

use HTML::Template;
use XML::LibXML;
use CGI;
use CGI::Carp 'fatalsToBrowser';
use Encode;
use UTILS;
#require "utils.pl";

my $page=CGI->new();
my $test;
my $template=HTML::Template->new(filename=>'prenotazioni.tmpl');
my $file='../data/prenotazioni.xml';
my $parser=XML::LibXML->new();
my $xml=$parser->parse_file($file);
my $nr_campi;
my $xml_campi=$parser->parse_file('../data/impianti.xml');

my ($news_title, $news_content)=UTILS::get_news($xml, $parser);     # genero le news da xml
my @loop_data=();

# scorro i risultati dell'estrazione e li inserisco in un hash

while($a=shift @$news_title and $b=shift @$news_content){
    my %row_data;
    $row_data{N_TITLE}=Encode::encode('utf8', $a);
    $row_data{N_CONTENT}=Encode::encode('utf8', $b);
    push(@loop_data, \%row_data);
}

my $disciplina=$page->param('disciplina');
$template->param(CAMPO=>$disciplina);
my $data=$page->param('data');
$data='2014-04-18' if not defined $data;
$data='2014-04-18' if $data eq '';

$template->param(NEWS=>\@loop_data);
my $table;
if(defined($disciplina)){
    $nr_campi=UTILS::getFields($xml_campi, $disciplina);
    $nr_campi=2 if not defined $nr_campi;
    for(1..$nr_campi){
	$table.=UTILS::getWeek($xml, $parser, $disciplina, $_, $data);
    }
    $template->param(TABLE=>$table);
}
print "Content-Type: text/html\n\n";
print $template->output;
