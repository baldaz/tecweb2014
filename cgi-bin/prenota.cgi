#!/usr/bin/perl -w

use strict;
use warnings;
use HTML::Template;
use XML::LibXML;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use UTILS;
use CGI::Session ('-ip_match');

$ENV{HTML_TEMPLATE_ROOT} = "../public_html/templates";
my $page = CGI->new();

my $session = CGI::Session->load() or die "ciao";

unless ($session->param("~logged-in")){
    print header(-type => 'text/html', -location => 'login.cgi');
}
my $is_logged = 1;
my $template = HTML::Template->new(filename=>'prenota.tmpl');
$template->param(LOGIN => $is_logged);
$template->param(USER => 'Admin');
$template->param(page => 'prenota.cgi');
$template->param(path => '<a href="viewB.cgi">Prenotazioni</a> >> Prenota');
my $file='../data/prenotazioni.xml';
my $parser=XML::LibXML->new();
my $xml=$parser->parse_file($file);

my @loop_news=UTILS::getNews($xml);

$template->param(NEWS=>\@loop_news);

#dati form
my($name, $surname, $tel, $email, $disciplina, $data, $ora, $campo, $test, $fase, $test_fase, $nr_campi, $xml_campi);

$fase = $page->param('fase');

if($fase==1){			# FASE 1
    $name=$page->param('nome');
    $surname=$page->param('cognome');
    $tel=$page->param('telefono');
    $email=$page->param('email');
    $disciplina=$page->param('disciplina');
}
else{				# FASE 2
    $name=$page->param('nome_h');
    $surname=$page->param('cognome_h');
    $tel=$page->param('numero_h');
    $email=$page->param('email_h');
    $disciplina=$page->param('disciplina_h');
    $data=$page->param('data');
    $ora=$page->param('ora');
    $campo=$page->param('campo');
    $test_fase=2;
}

$template->param(FORM1=>1);

if ($name eq '' or ($fase==2 and $name eq '')){		# fallimento, campi vuoti primo ingresso
    $test_fase=0;
}
else {
    $template->param(fase => 2);
    $template->param(FORM1 => 0);
    $template->param(button => "Conferma");
    $template->param(class_act => "active");
    $template->param(h_nome => $name);
    $template->param(h_cognome => $surname);
    $template->param(h_numero => $tel);
    $template->param(h_email => $email);
    $template->param(h_disciplina => $disciplina);
    $xml_campi = $parser->parse_file('../data/impianti.xml');
    $template->param(NR_CAMPI => UTILS::getFields($xml_campi, $disciplina));
}

if($test_fase==2){

    if(UTILS::checkform($xml, $disciplina, $campo, $data, $ora)){ # fallimento, prenotazione già presente nell'xml
	$test=-1;
    }
    else{ $test=1;}			# successo

    if($test==1){			# inserisco solo se non c'è stato un match di prenotazione
	my $new_element = 
	    "
    <prenotante>
     <nome>".$name."</nome>
      <cognome>".$surname."</cognome>
      <telefono>".$tel."</telefono>
      <email>".$email."</email>
      <disciplina>".$disciplina."</disciplina>
      <campo>".$campo."</campo>
      <data>".$data."</data>
      <ora>".$ora."</ora>
    </prenotante>
    ";
	
	my $pren=$xml->getElementsByTagName('prenotazioni')->[0];
	my $chunk=$parser->parse_balanced_chunk($new_element);
    
	$pren->appendChild($chunk);	# appendo il nuovo appena creato
	# $prenotazioni[0]->appendChild($chunk);

	open(OUT, ">$file");
	print OUT $xml->toString; 
	close OUT;
    }

#$template->param(DISCIPLINA=>$disciplina); # aggiorno il campo hidden disciplina, che fallbacka a Calcetto se lasciato undef


    if($test==-1){
	$template->param(SHOW_TBL=>1); 
	$test=0;
	my $table=UTILS::getWeek($xml, $disciplina, $campo, $data);
	$template->param(TBL=>1);
	$template->param(TEST=>$test);
	$template->param(TABLE=>$table);
	$template->param(fase=>2);
	$template->param(FORM1=>0);
	$template->param(class_act=>"active");
	$template->param(c_val=>$campo);
    }
    else {$template->param(TBL=>0);}
}

print "Content-Type: text/html\n\n";
print $template->output;
