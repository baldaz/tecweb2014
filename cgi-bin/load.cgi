#!/usr/bin/perl -w

use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use HTML::Template;
use XML::LibXML;
use feature 'switch';
use Encode;

require 'utils.pl';

my $cgi=CGI->new();

my $page=$cgi->param('page');
$page='home' if not defined($page);

my $file='../data/prenotazioni.xml';
my $parser=XML::LibXML->new("1.0", "UTF-8");
my $xml=$parser->parse_file($file);
my $template;

my ($news_title, $news_content)=&get_news($xml, $parser);     # genero le news da xml
my @loop_news=();

# scorro i risultati dell'estrazione e li inserisco in un hash

while($a=shift @$news_title and $b=shift @$news_content){
    my %row_data;
    $row_data{N_TITLE}=encode('utf-8',$a); # encoding dei me coioni
    $row_data{N_CONTENT}=encode('utf-8',$b); # encoding dei me coioni
    push(@loop_news, \%row_data);
}

given($page){
    when(/home/){
	$template=HTML::Template->new(filename=>'home.tmpl');
	$xml=$parser->parse_file('../data/sezioni.xml');
	my $description=&getDesc($xml, 'home');
	$description=encode('utf8', $description);
	$template->param(desc=>$description);
    }
    when(/impianti/){
	$template=HTML::Template->new(filename=>'impianti.tmpl');

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
    }
    when(/contatti/){
	$template=HTML::Template->new(filename=>'contatti.tmpl');
    }
    when(/prenotazioni/){
	$template=HTML::Template->new(filename=>'prenotazioni.tmpl');
    }
    default{
	$template=HTML::Template->new(filename=>'home.tmpl');
	$xml=$parser->parse_file('../data/sezioni.xml');
	my $description=&getDesc($xml, 'home');
	$description=encode('utf8', $description);
	$template->param(desc=>$description);
    }
}
    
$template->param(NEWS=>\@loop_news);
HTML::Template->config(utf8 => 1);

print "Content-Type: text/html\n\n", $template->output;
