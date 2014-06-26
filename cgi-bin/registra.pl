#!/usr/bin/perl

use strict;
use warnings;
use UTILS::UserService;

my $cgi = CGI->new();
my $utils = UTILS::UserService->new();
my ($name, $surname, $tel, $email, $password) = ($cgi->param('nome'), $cgi->param('cognome'), $cgi->param('telefono'), $cgi->param('email'), $cgi->param('password'));
my $file = '../data/profili.xml';
my $parser = XML::LibXML->new();
my $xml = $parser->parse_file($file);
my %find = $utils->get_generals($email);
my $registered = 0;
my $has_account = 0;
my $error = 0;

if($email !~ /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i || !$utils->validate_tel($tel) || !length($name) || !length($surname) || !length($tel) || !length($email) || !length($password)){
    $error = 1;
}
elsif(exists $find{not_found}){
    my $new_element = 
	"
    <profilo>
      <username>".$email."</username>
      <password>".$password."</password>
      <nome>".$name."</nome>
      <cognome>".$surname."</cognome>
      <telefono>".$tel."</telefono>
    </profilo>
    ";
	
    my $pren = $xml->getElementsByTagName('profili')->[0];
    my $chunk = $parser->parse_balanced_chunk($new_element);
    
    $pren->appendChild($chunk);	# appendo il nuovo appena creato
# $prenotazioni[0]->appendChild($chunk);
    
    open(OUT, ">$file");
    print OUT $xml->toString; 
    close OUT;
    $registered = 1;
}
else  { $has_account = 1;}
my %params = (
    title       => 'Centro sportivo - Registrazione',
    page        => 'registrazione',
    path        => '<a href="load.cgi?page=personale">Personale</a> >> Registrazione',
    LOGIN       => 0,
    has_account => $has_account,
    registered  => $registered,
    error       => $error,
    r_name      => $name,
    r_surname   => $surname,
    r_tel       => $tel,
    r_mail      => $email
    );
$utils->dispatcher('registrazione', %params);