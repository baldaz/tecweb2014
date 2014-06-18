#!/usr/bin/perl

use strict;
use warnings;
use UTILS::UserService

my $cgi = CGI->new;
my $utils = UTILS::UserService->new;
my ($name, $surname, $tel, $email, $password) = 
    ($cgi->param('nome'), $cgi->param('cognome'), $cgi->param('telefono'), $cgi->param('email'), $cgi->param('password'));
my $file = '../data/profili.xml';
my $parser = XML::LibXML->new();
my $xml = $parser->parse_file($file);
my %find = $utils->get_generals($email);
my $registered = 0;
if(exists $find{not_found}){
    my $key = 'tecweb2014';
    my $encrypted_pwd = crypt($key, $password);
    my $new_element = 
	"
    <profilo>
      <username>".$email."</username>
      <password>".$encrypted_pwd."</password>
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
my %params = (
    title       => 'Centro sportivo - Registrazione',
    page        => 'registrazione',
    path        => '<a href="load.cgi?page=personale">Personale</a> >> Registrazione',
    LOGIN       => 0,
    has_account => 0,
    registered  => $registered
    );
$utils->dispatcher('registrazione', %params);
