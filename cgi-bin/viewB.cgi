#!/usr/bin/perl -w

use HTML::Template;
use XML::LibXML;
use CGI;
use CGI::Carp 'fatalsToBrowser';

require "utils.pl";

my $page=CGI->new();
my $test;
my $template=HTML::Template->new(filename=>'prenotazioni.tmpl');
my $file='../data/prenotazioni.xml';
my $parser=XML::LibXML->new();
my $xml=$parser->parse_file($file);

my ($news_title, $news_content)=&get_news($xml, $parser);     # genero le news da xml
my @loop_data=();

# scorro i risultati dell'estrazione e li inserisco in un hash

while(@$news_title and @$news_content){
    my %row_data;
    $row_data{N_TITLE}=shift @$news_title;
    $row_data{N_CONTENT}=shift @$news_content;
    push(@loop_data, \%row_data);
}

my $disciplina=$page->param('disciplina');
$template->param(CAMPO=>$disciplina);

$template->param(NEWS=>\@loop_data);
my $table;
if(defined($disciplina)){
    for(1..3){
	$table.=&getWeek($xml, $parser, $disciplina, $_, '2014-04-18');
    }
    $template->param(TABLE=>$table);
}
print "Content-Type: text/html\n\n";
print $template->output;
