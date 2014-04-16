#!/usr/bin/perl -w

use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use HTML::Template;
use XML::LibXML;

require 'utils.pl';

my $cgi=CGI->new();

my $page=$cgi->param('page');
$page='impianti' if not defined($page);

my $template=HTML::Template->new(filename=>'impianti.tmpl');
my $file='../data/prenotazioni.xml';
my $parser=XML::LibXML->new();
my $xml=$parser->parse_file($file);

my ($news_title, $news_content)=&get_news($xml, $parser);     # genero le news da xml
my @loop_news=();

# scorro i risultati dell'estrazione e li inserisco in un hash

while(@$news_title and @$news_content){
    my %row_data;
    $row_data{N_TITLE}=shift @$news_title;
    $row_data{N_CONTENT}=shift @$news_content;
    push(@loop_news, \%row_data);
}

$template->param(NEWS=>\@loop_news);

$xml=$parser->parse_file('../data/impianti.xml');
# estraggo il numero di campi
my $n_calcetto=&getFields($xml, 'Calcetto');
my $n_calciotto=&getFields($xml, 'Calciotto');
my $n_tennis=&getFields($xml, 'Tennis');
my $n_pallavolo=&getFields($xml, 'Pallavolo');
my $n_bvolley=&getFields($xml, 'Beach Volley');

my @img=&getImg($xml);
my @loop_img=();

foreach(@img){
    my %row_data;
    $row_data{src}=$_;
    push(@loop_img, \%row_data);
}

$template->param(imm_campi=>\@loop_img);

$template->param(n_calcetto=>$n_calcetto);
$template->param(n_calciotto=>$n_calciotto);
$template->param(n_tennis=>$n_tennis);
$template->param(n_pallavolo=>$n_pallavolo);
$template->param(n_bvolley=>$n_bvolley);

print "Content-Type: text/html\n\n";
print $template->output;
