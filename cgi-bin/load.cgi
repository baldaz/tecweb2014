#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use HTML::Template;
use feature 'switch';
use UTILS;
use CGI::Session ('-ip-match');

my $cgi=CGI->new();

my $page=$cgi->param('page') || 'home';
my $is_logged;
my $session=CGI::Session->load() or die "ciao";
if($session->param("~logged-in")){
	$is_logged=1;
}
else{
	$is_logged=UTILS::login($session, $cgi);
}

my $xml=UTILS::loadXml('../data/prenotazioni.xml');
my $template;
my @loop_news=UTILS::getNews($xml);

given($page){
    when(/home/){ 
	$template=HTML::Template->new(filename=>'home.tmpl');
	$xml=UTILS::loadXml('../data/sezioni.xml');
	my $description=UTILS::getDesc($xml, 'home');
	$description=Encode::encode('utf8', $description);
	$template->param(desc=>$description);
	$template->param(LOGIN => $is_logged);
	$template->param(USER => 'Admin');
    }
    when(/impianti/){
	$template=HTML::Template->new(filename=>'impianti.tmpl');

	$xml=UTILS::loadXml('../data/impianti.xml');
  	           # estraggo il numero di campi
	my $n_calcetto=UTILS::getFields($xml, 'Calcetto');
	my $n_calciotto=UTILS::getFields($xml, 'Calciotto');
	my $n_tennis=UTILS::getFields($xml, 'Tennis');
	my $n_pallavolo=UTILS::getFields($xml, 'Pallavolo');
	my $n_bvolley=UTILS::getFields($xml, 'Beach Volley');

	my @img=UTILS::getImg($xml);
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
    when(/corsi/){
	$template=HTML::Template->new(filename=>'corsi.tmpl');
	my $xml=UTILS::loadXml('../data/corsi.xml');
	my $tbl_corsi=UTILS::getOrari($xml);
	my $table=UTILS::getPrezziCorsi($xml);
	$table=Encode::encode('utf8', $table); # boh, senza encoding sfasa l'UTF-8 del template, BUG
	$template->param(tbl=>$table);
	$template->param(tbl_corsi=>$tbl_corsi);
    }
    when(/login/){
	$template=HTML::Template->new(filename=>'login.tmpl');
	$template->param(footer=>UTILS::footer);
    }
    default{
#	$template=HTML::Template->new(filename=>'home.tmpl');
#	$xml=UTILS::loadXml('../data/sezioni.xml');
#	my $description=UTILS::getDesc($xml, 'home');
#	$description=Encode::encode('utf8', $description);
#	$template->param(desc=>$description);
	print $cgi->redirect('load.cgi?page=home');
    }
}
    
$template->param(NEWS=>\@loop_news);
HTML::Template->config(utf8 => 1);

print "Content-Type: text/html\n\n", $template->output;
