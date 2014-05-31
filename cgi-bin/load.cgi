#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use UTILS;

my $cgi = CGI->new();
my $page = $cgi->param('page') || 'home';
my $xml = UTILS::loadXml('../data/sezioni.xml');
my $description = UTILS::getDesc($xml, $page);
$description = Encode::encode('utf8', $description);
my $is_logged = UTILS::is_logged;

my %routes = (
    'home'     => \&index,
    'impianti' => \&impianti,
    'contatti' => \&contatti,
    'corsi'    => \&corsi,
    );

if( grep { $page eq $_} keys %routes){
    $routes{$page}->();
}
else {
    $description = UTILS::getDesc($xml, 'home');
    $routes{'home'}->();
}

sub index {
    my %params = (
	page  => 'home',
	path  => 'Home',
	desc  => $description,
	LOGIN => $is_logged,
	USER  => 'Admin'
	);

    UTILS::dispatcher('index', %params);
}

sub impianti {
    my @discipline = ('Calcetto', 'Calciotto', 'Tennis', 'Pallavolo', 'Beach Volley');
    my $xml_imp = UTILS::loadXml('../data/impianti.xml');
    # estraggo il numero di campi
    my @d_param = map { UTILS::getFields($xml_imp, $_) } @discipline;
    my @img = UTILS::getImg($xml_imp);
    my @loop_img = ();

    push @loop_img, {src => $_} foreach(@img); # push hash anonimi per generazione immagini

    my %params = (
	page        => 'impianti',
	path        => 'Impianti',
	imm_campi   => \@loop_img,
	n_calcetto  => $d_param[0],
	n_calciotto => $d_param[1],
	n_tennis    => $d_param[2],
	n_pallavolo => $d_param[3],
	n_bvolley   => $d_param[4],
	LOGIN       => $is_logged,
	USER        => 'Admin'
	);
    UTILS::dispatcher('impianti', %params);
}

sub corsi {
    my $xml_corsi = UTILS::loadXml('../data/corsi.xml');
    my $tbl_corsi = UTILS::getOrari($xml_corsi);
    my $table = UTILS::getPrezziCorsi($xml_corsi);
    $table = Encode::encode('utf8', $table); # boh, senza encoding sfasa l'UTF-8 del template, BUG
    my %params = (
	page      => 'corsi',
	path      => 'Corsi',
	tbl       => $table,  
	tbl_corsi => $tbl_corsi,
	LOGIN     => $is_logged,
	USER      => 'Admin'
	);
    UTILS::dispatcher('corsi', %params);
}

sub contatti {
    my %params = (
	page  => 'contatti',
	path  => 'Contatti',
	LOGIN => $is_logged,
	USER  => 'Admin'
	);
    UTILS::dispatcher('contatti', %params);
}
