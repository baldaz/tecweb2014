#!/usr/bin/perl -w

use CGI;
use XML::LibXML;
use CGI::Carp 'fatalsToBrowser';

my $page=new CGI;

my $file = '../data/prenotazioni.xml' or die "problema apertura";

my $parser = XML::LibXML->new();

#apertura file e lettura input
my $doc = $parser->parse_file($file) or die "problema parser";

#estrazione elemento radice
my $radice= $doc->getDocumentElement or die "problema getDoc";
my @prenotazioni = $radice->getElementsByTagName('prenotazioni') or die "problema getDoc2!!";

#dati form

my $name=$page->param('nome');
my $surname=$page->param('cognome');
my $tel=$page->param('telefono');
my $email=$page->param('email');
my $disciplina=$page->param('disciplina');
my $data=$page->param('data');
my $ora=$page->param('ora');

my $new_element = 
    "<prenotante>
          <nome>".$name."</nome>
          <cognome>".$surname."</cognome>
          <telefono>".$tel."</telefono>
          <email>".$email."</email>
          <disciplina>".$disciplina."</disciplina>
          <data>".$data."</data>
          <ora>".$ora."</ora>
     </prenotante>
      ";

my $chunk = $parser->parse_balanced_chunk($new_element) or die "problema parse_balanced_chunk";
#appendo il nuovo appena creato
$prenotazioni[0]->appendChild($chunk);

open(OUT, ">$file") or die("Non riesco ad aprire il file in scrittura");
#scrivo effettivamente sul file
print OUT $doc->toString or die "problema finale"; 
#chiudo file
close (OUT);      
