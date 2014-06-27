#!/usr/bin/perl -w

use strict;
use warnings;
use UTILS::UserService;

my $cgi = CGI->new();
my $utils = UTILS::UserService->new();
my $page = $cgi->param('page') || 'home';
my $disciplina = $cgi->param('disciplina') || 'Calcetto';
my $today = $utils->_today;
my $data = $cgi->param('data') || $today;
$data = $today if $data eq '';
my $description = $utils->getDesc($page);
my %sess_params = $utils->session_params($cgi);
    
my %routes = (
    'home'          => \&index,
    'impianti'      => \&impianti,
    'contatti'      => \&contatti,
    'corsi'         => \&corsi,
    'prenotazioni'  => \&prenotazioni,
    'registrazione' => \&registrazione,
    'personale'     => \&personale,
    'prenota'       => \&prenota,
    'edit_personal' => \&edit_personal
    );

if( grep { $page eq $_} keys %routes){
    $routes{$page}->();
}
else {
    $description = $utils->getDesc('home');
    $routes{'home'}->();
}

sub index {
#    print "Content-type: text/html\n\n";
#    print $attempt;
#    print $utils->get_id;
    my %params = (
	title   => 'Centro sportivo',
	page    => 'home',
	path    => 'Home',
	desc    => $description,
	LOGIN   => $sess_params{is_logged},
	USER    => $sess_params{profile},
	attempt => $sess_params{attempt}
	);

    $utils->dispatcher('index', %params);
}

sub impianti {
    my @discipline = ('Calcetto', 'Calciotto', 'Tennis', 'Pallavolo', 'Beach Volley');
    # estraggo il numero di campi
    my @d_param = map { $utils->getFields($_) } @discipline;
#    my @img = $utils->getImg;
#    my @loop_img = ();

#    push @loop_img, {src => $_} foreach(@img); # push hash anonimi per generazione immagini

    my %params = (
	title => 'Centro sportivo - Impianti',
	page        => 'impianti',
	path        => 'Impianti',
#	imm_campi   => \@loop_img,
	n_calcetto  => $d_param[0],
	n_calciotto => $d_param[1],
	n_tennis    => $d_param[2],
	n_pallavolo => $d_param[3],
	n_bvolley   => $d_param[4],
	LOGIN       => $sess_params{is_logged},
	USER        => $sess_params{profile},
	attempt     => $sess_params{attempt}
	);
    $utils->dispatcher('impianti', %params);
}

sub corsi {
    my @loop_prices = $utils->list_prices;
    my @loop_scheduling = $utils->list_scheduling;
    my %params = (
	title => 'Centro sportivo - Corsi',
	page      => 'corsi',
	path      => 'Corsi',
	courses_price => \@loop_prices,
	courses_scheduling => \@loop_scheduling,
	LOGIN     => $sess_params{is_logged},
	USER      => $sess_params{profile},
	attempt   => $sess_params{attempt}
	);
    $utils->dispatcher('corsi', %params);
}

sub contatti {
    my $mail = '';
    if($sess_params{is_logged}){
	$mail = $sess_params{profile};
    }
    my %params = (
	title   => 'Centro sportivo - Contatti',
	page    => 'contatti',
	path    => 'Contatti',
	email   => $mail,
	LOGIN   => $sess_params{is_logged},
	USER    => $sess_params{profile},
	attempt => $sess_params{attempt}
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
    $table = Encode::decode('utf8', $table);
    my %params = (
	title   => 'Centro sportivo - Prenotazioni',
	page    => 'prenotazioni',
	path    => 'Prenotazioni',
	LOGIN   => $sess_params{is_logged},
	USER    => $sess_params{profile},
	attempt => $sess_params{attempt},
	TABLE   => $table
    );

    $utils->dispatcher('prenotazioni', %params);
}

sub registrazione {
    print $cgi->header(-location => 'load.cgi?page=personale') unless(!$sess_params{is_logged});
    my %params = (
	title       => 'Centro sportivo - Registrazione',
	page        => 'registrazione',
	path        => '<a href="load.cgi?page=personale">Personale</a> >> Registrazione',
	LOGIN       => 0,
        has_account => 0,
	registered  => 0
	);
    $utils->dispatcher('registrazione', %params);
}

sub personale {
    my %generals = $utils->get_generals($sess_params{profile});
    my @prens = $utils->get_prenotations($sess_params{profile});
    my %params = ();
    if(!@prens){
	%params = (
	    title     => 'Centro sportivo - Area Personale',
	    page      => 'personale',
	    path      => 'Personale',
	    name      => $generals{name},
	    surname   => $generals{surname},
	    mail      => $sess_params{profile},
	    tel       => $generals{tel},
	    is_logged => $sess_params{is_logged},
	    LOGIN     => $sess_params{is_logged},
	    USER      => $sess_params{profile},
	    attempt   => $sess_params{attempt},
	    has_pren  => 0
	    );
    }
    else {
	%params = (
	    title     => 'Centro sportivo - Area Personale',
	    page      => 'personale',
	    path      => 'Personale',
	    name      => $generals{name},
	    surname   => $generals{surname},
	    mail      => $sess_params{profile},
	    tel       => $generals{tel},
	    is_logged => $sess_params{is_logged},
	    LOGIN     => $sess_params{is_logged},
	    USER      => $sess_params{profile},
	    attempt   => $sess_params{attempt},
	    has_pren  => 1,
	    pren_loop => \@prens
	    );
    }
    $utils->dispatcher('personale', %params);
}

sub edit_personal {
    my %generals = $utils->get_generals($sess_params{profile});
    my %params = (
	title     => 'Centro sportivo - Area Personale',
	page      => 'personale',
	path      => 'Personale',
	name      => $generals{name},
	surname   => $generals{surname},
	mail      => $sess_params{profile},
	tel       => $generals{tel},
	is_logged => $sess_params{is_logged},
	LOGIN     => $sess_params{is_logged},
	USER      => $sess_params{profile},
	attempt   => $sess_params{attempt}
	);
    $utils->dispatcher('edit_personal', %params);
}

sub prenota {
    my %params = (
	title     => 'Centro sportivo - Prenota',
	page      => 'prenota',
	path      => '<a href="load.cgi?page=prenotazioni">Prenotazioni</a> >> Prenota',
	is_logged => $sess_params{is_logged},
	LOGIN     => $sess_params{is_logged},
	USER      => $sess_params{profile},
	attempt   => $sess_params{attempt},
	SHOW_TBL  => 0,
	TBL       => 0,
	test      => 1,
	);
    $utils->dispatcher('prenota', %params);
}
