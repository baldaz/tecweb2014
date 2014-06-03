#!/usr/bin/perl -w

use strict;
use warnings;
use UTILS;

my $cgi = CGI->new();
my $utils = UTILS->new('../data/prenotazioni.xml');
my $page = $cgi->param('page') || 'home';
my $disciplina = $cgi->param('disciplina');
my $today = $utils->_today;
my $data = $cgi->param('data') || $today;
$data = $today if $data eq '';
my $description = Encode::encode('utf8', $utils->getDesc($page));
my $is_logged = $utils->is_logged;

my %routes = (
    'home'          => \&index,
    'impianti'      => \&impianti,
    'contatti'      => \&contatti,
    'corsi'         => \&corsi,
    'prenotazioni'  => \&prenotazioni,
    'registrazione' => \&registrazione
    );

if( grep { $page eq $_} keys %routes){
    $routes{$page}->();
}
else {
    $description = Encode::encode('utf8', $utils->getDesc('home'));
    $routes{'home'}->();
}

sub index {
    my %params = (
	title => 'Centro sportivo',
	page  => 'home',
	path  => 'Home',
	desc  => $description,
	LOGIN => $is_logged,
	USER  => 'Admin'
	);

    $utils->dispatcher('index', %params);
}

sub impianti {
    my @discipline = ('Calcetto', 'Calciotto', 'Tennis', 'Pallavolo', 'Beach Volley');
    # estraggo il numero di campi
    my @d_param = map { $utils->getFields($_) } @discipline;
    my @img = $utils->getImg;
    my @loop_img = ();

    push @loop_img, {src => $_} foreach(@img); # push hash anonimi per generazione immagini

    my %params = (
	title => 'Centro sportivo - Impianti',
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
    $utils->dispatcher('impianti', %params);
}

sub corsi {
    my $tbl_corsi = $utils->getOrari;
    my $table = $utils->getPrezziCorsi;
    $table = Encode::encode('utf8', $table); # boh, senza encoding sfasa l'UTF-8 del template, BUG
    my %params = (
	title => 'Centro sportivo - Corsi',
	page      => 'corsi',
	path      => 'Corsi',
	tbl       => $table,  
	tbl_corsi => $tbl_corsi,
	LOGIN     => $is_logged,
	USER      => 'Admin'
	);
    $utils->dispatcher('corsi', %params);
}

sub contatti {
    my %params = (
	title => 'Centro sportivo - Contatti',
	page  => 'contatti',
	path  => 'Contatti',
	LOGIN => $is_logged,
	USER  => 'Admin'
	);
    $utils->dispatcher('contatti', %params);
}

sub prenotazioni {

    my @discipline = ('Calcetto', 'Calciotto', 'Pallavolo', 'Beach Volley', 'Tennis'); 

    $disciplina = $discipline[0] unless grep { $_ eq $disciplina } @discipline; # sanity check
    
    my $nr_campi = $utils->getFields($disciplina);
    $nr_campi = 2 if not defined $nr_campi;
    my $table = "<h3>Tabelle prenotazione:</h3>";
    for(1..$nr_campi){
	$table.= $utils->getWeek($disciplina, $_, $data);
    }

    my %params = (
	title => 'Centro sportivo - Prenotazioni',
	page  => 'prenotazioni',
	path  => 'Prenotazioni',
	LOGIN => $is_logged,
	USER  => 'Admin',
	TABLE => $table
    );

    $utils->dispatcher('prenotazioni', %params);
}

sub registrazione {
    my %params = (
	title => 'Centro sportivo - Registrazione',
	page  => 'registrazione',
	path  => 'Registrazione',
	LOGIN => 0
	);
    $utils->dispatcher('registrazione', %params);
}
