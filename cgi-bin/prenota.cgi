#!/usr/bin/perl -w

#print "Content-Type: text/html\n\n";

use HTML::Template;
use XML::LibXML;
use CGI;
use CGI::Carp 'fatalsToBrowser';

require "utils.pl";

my $page=CGI->new();
my $test;
my $template=HTML::Template->new(filename=>'prenota.tmpl');
my $file='../data/prenotazioni.xml';
my $parser=XML::LibXML->new();
my $xml=$parser->parse_file($file);

#dati form

my $name=$page->param('nome');
my $surname=$page->param('cognome');
my $tel=$page->param('telefono');
my $email=$page->param('email');
my $disciplina=$page->param('disciplina');
my $data=$page->param('data');
my $ora=$page->param('ora');

if ($name eq ''){		# fallimento, campi vuoti primo ingresso
    $test=0;
}
elsif(&checkform($xml, $parser, $disciplina, $data, $ora)){ # fallimento, prenotazione già presente nell'xml
    $test=-1;
}
else{ $test=1;}			# successo


my $new_element = 
    "
      <prenotante>
        <nome>".$name."</nome>
        <cognome>".$surname."</cognome>
        <telefono>".$tel."</telefono>
        <email>".$email."</email>
        <disciplina>".$disciplina."</disciplina>
        <data>".$data."</data>
        <ora>".$ora."</ora>
        </prenotante>
      ";

my $pren=$xml->getElementsByTagName('prenotazioni')->[0];
my $chunk=$parser->parse_balanced_chunk($new_element);
    #appendo il nuovo appena creato
$pren->appendChild($chunk);
#$prenotazioni[0]->appendChild($chunk);

open(OUT, ">$file");
    #scrivo effettivamente sul file
print OUT $xml->toString; 
    #chiudo file
close (OUT);

if($test!=0){
    if($test==-1){$test=0}
    my $table=&getWeek($xml, $parser, $disciplina, $data);
    $template->param(TBL=>1);
    $template->param(TEST=>$test);
    $template->param(TABLE=>$table);
}
else {$template->param(TBL=>0);}

print "Content-Type: text/html\n\n";
print $template->output;
