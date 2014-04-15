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

my ($news_title, $news_content)=&get_news($xml, $parser);     # genero le news da xml
my @loop_data=();

# scorro i risultati dell'estrazione e li inserisco in un hash

while(@$news_title and @$news_content){
    my %row_data;
    $row_data{N_TITLE}=shift @$news_title;
    $row_data{N_CONTENT}=shift @$news_content;
    push(@loop_data, \%row_data);
}

$template->param(NEWS=>\@loop_data);

#dati form

my $name=$page->param('nome');
my $surname=$page->param('cognome');
my $tel=$page->param('telefono');
my $email=$page->param('email');
my $disciplina=$page->param('disciplina');
my $data=$page->param('data');
my $ora=$page->param('ora');
my $campo=$page->param('campo');

if ($name eq ''){		# fallimento, campi vuoti primo ingresso
    $test=0;
}
elsif(&checkform($xml, $parser, $disciplina, $campo, $data, $ora)){ # fallimento, prenotazione già presente nell'xml
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

$template->param(DISCIPLINA=>$disciplina); # aggiorno il campo hidden disciplina, che fallbacka a Calcetto se lasciato undef

if($test!=0){
    if($test==-1){$test=0}
    my $table=&getWeek($xml, $parser, $disciplina, $campo, $data);
    $template->param(TBL=>1);
    $template->param(TEST=>$test);
    $template->param(TABLE=>$table);
}
else {$template->param(TBL=>0);}

print "Content-Type: text/html\n\n";
print $template->output;
