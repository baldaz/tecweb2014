#!/usr/bin/perl -w

use CGI;
use CGI::Carp 'fatalsToBrowser';
use XML::LibXML;

require "utils.pl";

$page=new CGI;
my $test;
my $file='../data/prenotazioni.xml' or die "problema apertura";

my $parser=XML::LibXML->new();

#apertura file e lettura input
my $doc=$parser->parse_file($file) or die "problema parser";

#estrazione elemento radice
my $radice=$doc->getDocumentElement or die "problema getDoc";
my @prenotazioni=$radice->getElementsByTagName('prenotazioni') or die "problema getDoc2!!";

#dati form

my $name=$page->param('nome');
my $surname=$page->param('cognome');
my $tel=$page->param('telefono');
my $email=$page->param('email');
my $disciplina=$page->param('disciplina');
my $data=$page->param('data');
my $ora=$page->param('ora');

if ($name eq ''){		# fallimento, campi vuoti caso base primo ingresso
    $test=0;
}
elsif(&checkform($doc, $parser, $disciplina, $data, $ora)){ # fallimento, prenotazione già presente nell'xml
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

my $chunk=$parser->parse_balanced_chunk($new_element) or die"problema parse_balanced_chunk";
    #appendo il nuovo appena creato
$prenotazioni[0]->appendChild($chunk);

open(OUT, ">$file") or die("Non riesco ad aprire il file in scrittura");
    #scrivo effettivamente sul file
print OUT $doc->toString or die "problema finale"; 
    #chiudo file
close (OUT); 


$title="Prenotazioni";
&init($page, $title);

if(defined($page->param('disciplina'))){
	$disc=$page->param('disciplina');
print'
<div id="container">
	<div id="header">
		<h1>Centro Sportivo</h1>

		<div id="path">

		</div>
	</div>

	<div id="nav">
		<ul>
		<li><a href="./index.html">Home</a></li>
		<li><a href="./calcetto.html">Calcio a 5</a></li>
		<li><a href="./calciotto.html">Calciotto</a></li>
		<li><a href="./tennis.html">Tennis</a></li>
		<li><a href="./beachvolley.html"> <span xml:lang="en">Beach Volley</span></a></li>
		<li><a href="./pallavolo.html">Pallavolo</a></li>
		<li><a href="./artimarziali.html">Arti Marziali</a></li>
		<li><a href="./fitness.html">Fitness</a></li>
		<li><a href="./contatti.html">Contatti</a></li>
        <li><a id="active">Prenota</a></li>
		</ul>
	</div>

	<div id="content">
		<form method="POST" action="">
			<fieldset>
				<legend><h2>PRENOTAZIONE</h2></legend>
				<label>Nome:
				    <input type="text" name="nome" id="nome" value="" />
                </label>
				<label>Cognome: 
				    <input type="text" name="cognome" id="cognome" value="" />
                </label>    
				<label>Telefono: 
				    <input type="text" name="telefono" id="telefono" value="" />
                </label>    
				<label >Email:
				    <input type="email" name="email" id="email" value="" />
                 </label>    
				<label> Ora:
				    <select name="ora" id="ora">
				    	<option value="16:00">16:00</option>
				    	<option value="17:00">17:00</option>
				    	<option value="18:00">18:00</option>
				    </select> 
                 </label>
                 <input type="hidden" name="disciplina" id="disciplina" value="'.$disc.'" />
                 <input type="hidden" name="test" id="test" value="0" />
				<!--
				<label for="giorno"> Giorno: </label>
				<select name="giorno" id="giorno"><option value="01">01</option><option value="02">02</option><option value="03">03</option></select>
				<label for="mese"> Mese: </label>
				<select name="mese" id="mese"><option value="Calcetto">Calcetto</option><option value="Calciotto">Calciotto</option><option value="Pallavolo">Pallavolo</option></select> 
				<label for="anno"> Anno: </label>
				<select name="anno" id="anno"><option value="Calcetto">Calcetto</option><option value="Calciotto">Calciotto</option><option value="Pallavolo">Pallavolo</option></select>  
			-->
				<label>Giorno: 
   				<input type="date" name="data" id="data" >
  				</label>
            </fieldset>
            <fieldset>
  		        <input type="reset"  value="Resetta il form" class="button" />
  		        <input type="submit" value="Invia" class="button" />
            </fieldset>
	</form>
	';

	if($test==-1){print 'FALLIMENDOG'; &get_week($doc, $parser, $disc, $data)}
	elsif($test==1){print 'SUCCESDOG';}  
	
	print '
	</div>
	<div id="news_container">
	<div id="news">
			<h2>NEWS</h2>
		<ul>
		      <li>NEW1</li>
		      <li>NEW2</li>
		      <li>ew3New3NewNew3New3New3New3NewNew3New3New3NewNew3New3New3</li>
		      <li>New4</li>
		</ul>
	</div>
	</div>
	
';

}
else{

	print '

	<div id="container">
	<div id="header">
		<h1>Centro Sportivo</h1>

		<div id="path">

		</div>
	</div>

	<div id="nav">
		<ul>
		<li><a href="./index.html">Home</a></li>
		<li><a href="./calcetto.html">Calcio a 5</a></li>
		<li><a href="./calciotto.html">Calciotto</a></li>
		<li><a href="./tennis.html">Tennis</a></li>
		<li><a href="./beachvolley.html"> <span xml:lang="en">Beach Volley</span></a></li>
		<li><a href="./pallavolo.html">Pallavolo</a></li>
		<li><a href="./artimarziali.html">Arti Marziali</a></li>
		<li><a href="./fitness.html">Fitness</a></li>
		<li><a href="./contatti.html">Contatti</a></li>
        <li><a id="active">Prenota</a></li>
		</ul>
	</div>

	<div id="content">
		<form action="" method="GET">
				<label> Disciplina:
				    <select name="disciplina" id="disciplina"><option value="Calcetto">Calcetto</option><option value="Calciotto">Calciotto</option><option value="Pallavolo">Pallavolo</option></select> 
                 </label>
                 <input type="submit" value="Invia" class="button" />
		</form>
	</div>';
	&print_news($page);
}
&footer($page);
print $page->end_html;
