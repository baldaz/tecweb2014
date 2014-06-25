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

if(!$utils->validate_mail($email) || !$utils->validate_tel($tel) || !$name || !$surname || !$tel || !$email || !$password || length($name) > 20 || length($surname) > 20 || length($tel) > 10 || length($email) > 30 || length($password) > 20){
    $error = 1;
    
#    print "Content-type: text/html\n\n";
#    print $utils->validate_mail($email);
}
elsif(exists $find{not_found}){
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
