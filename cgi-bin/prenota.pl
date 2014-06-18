#!/usr/bin/perl

use strict;
use warnings;
use UTILS::UserService;

my $cgi = CGI->new;
my $disciplina = $cgi->param("disciplina");
my $data = $cgi->param("data");
my $ora = $cgi->param("ora");
my $utils = UTILS::UserService->new();
my $is_logged = $utils->is_logged;
my $email = $utils->get_user;
my $file = '../data/prenotazioni.xml';
my $parser = XML::LibXML->new();
my $xml = $parser->parse_file($file);
my ($show_tbl, $table, $tbl, $test, $campo);

$campo = $utils->select_field($disciplina, $data, $ora);

if($campo != -1){
    my $new_element = 
	"
    <prenotante>
      <email>".$email."</email>
      <disciplina>".$disciplina."</disciplina>
      <campo>".$campo."</campo>
      <data>".$data."</data>
      <ora>".$ora."</ora>
    </prenotante>
    ";
	
    my $pren = $xml->getElementsByTagName('prenotazioni')->[0];
    my $chunk = $parser->parse_balanced_chunk($new_element);
    
    $pren->appendChild($chunk);	# appendo il nuovo appena creato
    # $prenotazioni[0]->appendChild($chunk);
    
    open(OUT, ">$file");
    print OUT $xml->toString; 
    close OUT;
    $test = 1;
    $show_tbl = 0;
    $tbl = 0;
}
else{
    $show_tbl = 0; 
    $test = 0;
    $table = $utils->getWeek($disciplina, $campo, $data);
    $tbl = 1;
}

my %params = (
    LOGIN => $is_logged,
    USER => 'Admin',
    page => 'prenota',
    path => '<a href="load.cgi?page=prenotazioni">Prenotazioni</a> >> Prenota',
    is_logged => $is_logged,
    TEST     => $test,
    SHOW_TBL => $show_tbl,
    TBL      => $tbl,
    TABLE    => $table,
    );

$utils->dispatcher('prenota', %params);
=pod
print "Content-type:text/html\n\n";
my $ret = $utils->select_field('Calcetto', '2014-04-18', '16:00');
print $ret;
=cut
