#!/usr/bin/perl -w

use HTML::Template;
use XML::LibXML;
use CGI;
use CGI::Carp 'fatalsToBrowser';
use Encode;

require "utils.pl";

my $page=CGI->new();
my $test;
my $template=HTML::Template->new(filename=>'prenotazioni.tmpl');
my $file='../data/prenotazioni.xml';
my $parser=XML::LibXML->new();
my $xml=$parser->parse_file($file);
my $nr_campi;
my $xml_campi=$parser->parse_file('../data/impianti.xml');

my ($news_title, $news_content)=&get_news($xml, $parser);     # genero le news da xml
my @loop_data=();

# scorro i risultati dell'estrazione e li inserisco in un hash

while($a=shift @$news_title and $b=shift @$news_content){
    my %row_data;
    $row_data{N_TITLE}=encode('utf8', $a);
    $row_data{N_CONTENT}=encode('utf8', $b);
    push(@loop_data, \%row_data);
}

my $disciplina=$page->param('disciplina');
$template->param(CAMPO=>$disciplina);

$template->param(NEWS=>\@loop_data);
my $table;
if(defined($disciplina)){
    $nr_campi=&getFields($xml_campi, $disciplina);
    for(1..$nr_campi){
	$table.=&getWeek($xml, $parser, $disciplina, $_, '2014-04-18');
    }
    $template->param(TABLE=>$table);
}
print "Content-Type: text/html\n\n";
print $template->output;
