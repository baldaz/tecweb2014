#!/usr/bin/perl -w

package UTILS;

use strict;
use warnings;
use XML::LibXML;
use CGI qw/:standard/;
use CGI::Carp qw/warningsToBrowser fatalsToBrowser/;
use CGI::Session qw/-ip-match/;
use DateTime;
use Date::Parse;
use HTML::Template;
use Encode;

$ENV{HTML_TEMPLATE_ROOT} = "../public_html/templates";

# ausiliarie

my $get = sub {
    my $self = shift;
    my ($node, $name) = @_;

    my $value = "(Element $name not found)";
    my @targets = $node->getElementsByTagName($name);
    
    if (@targets) {
	my $target = $targets[0];
	$value = $target->textContent;
    }
    return $value;
};

my $text = sub {
    my $self = shift;
    my (@data) = @_;
    my @ret = map { $_->textContent } @data;
    return @ret;
};

sub new {
    my $class = shift;
    my $self = bless {
	xml_path => shift || '../data/prenotazioni.xml'
    }, $class;
    return $self;
}

sub load_xml {
    my $self = shift;
    if(@_){
	$self->{xml_path} = shift;
    }
    return XML::LibXML->load_xml(location => $self->{xml_path});
}

# controllo prenotazione su file xml

sub checkform {
    my($self, $disciplina, $campo, $data, $ora) = @_;
    $self->load_xml('../data/prenotazioni.xml');
    my $root = $self->load_xml->getDocumentElement;
    $self->load_xml->documentElement->setNamespace("www.prenotazioni.it", "p");
    #controllo se esiste un match (prenotazione gia' presa)
    my $ret = $root->exists("//p:prenotante[p:disciplina='$disciplina' and p:data='$data' and p:ora='$ora' and p:campo='$campo']/p:nome");
    return $ret;
}

# controllo numero telefonico

sub check_tel {
    my ($self, $number) = @_;
    if($number = ~/^(\d)+$/){
	return 0;
    }
    else{ return 1; }
}

# estrae il contenuto di un nodo, analogo a text(), ma piu utile nei casi di html e CDATA nel file XML

sub toText {
    my (@data) = @_;
    my @ret = map { $_->textContent } @data;
    return @ret;
}

# estrae le news dal file xml

sub loadNews {
    my $self = shift;
    my $xml = $self->load_xml;
    $xml->documentElement->setNamespace("www.prenotazioni.it","p");
    my @titles = $xml->findnodes("//p:new/p:titolo");
    @titles = $self->$text(@titles);
    my @contents = $xml->findnodes("//p:new/p:contenuto");
    @contents = $self->$text(@contents);
    return (\@titles, \@contents);
}

sub _today {
    my $self = shift;
    my $dt = DateTime->today->ymd("-");
    return $dt;
}

sub getNews {
    my $self = shift;
    my $xml = $self->load_xml('../data/prenotazioni.xml');
    my ($news_title, $news_content) = $self->loadNews($xml);     # genero le news da xml
    my @loop_news = ();

# scorro i risultati dell'estrazione e li inserisco in un hash

    while($a = shift @$news_title and $b = shift @$news_content){
	my %row_data;
	$row_data{N_TITLE} = encode('utf-8', $a); # encoding dei me coioni
	$row_data{N_CONTENT} = encode('utf-8', $b); # encoding dei me coioni
	push(@loop_news, \%row_data);
    }
    return @loop_news;
}

# estrae il numero di campi di una data disciplina dal file xml

sub getFields {
    my ($self, $disciplina) = @_;
    my $xml = $self->load_xml('../data/impianti.xml');
    $xml->documentElement->setNamespace("www.impianti.it","i");
    my @ret_n = $xml->findnodes("//i:impianto[i:disciplina='$disciplina']/i:campi");
    @ret_n = $self->$text(@ret_n);
    return $ret_n[0];
}

# estrae il perscorsi delle immagini degli impianti dal file xml

sub getImg {
    my $self = shift;
    my $xml = $self->load_xml('../data/impianti.xml');
    $xml->documentElement->setNamespace("www.impianti.it","i");
    my @ret_img = $xml->findnodes("//i:impianto/i:src");
    return $self->$text(@ret_img);
}

# estrae la descrizione di una data sezione dal file xml
 
sub getDesc {
    my ($self, $nome) = @_;
    my $xml = $self->load_xml('../data/sezioni.xml');
    $xml->documentElement->setNamespace("www.sezioni.it","s");
    my @ret_desc = $xml->findnodes("//s:sezione[\@nome='$nome']/s:contenuto");
    @ret_desc = $self->$text(@ret_desc);
    my $ret_descr.= join( '', map { $_ } @ret_desc );
}

sub getWeek {
    my ($self, $discipline, $campo, $p_date) = @_;
    my $xmldoc = $self->load_xml('../data/prenotazioni.xml');
    my $root = $xmldoc->getDocumentElement;
    $xmldoc->documentElement->setNamespace("www.prenotazioni.it", "p");
    my @dates = $root->findnodes("//p:prenotante[p:disciplina='".$discipline."' and p:campo='".$campo."']/p:data");

    @dates = $self->$text(@dates);

    my @split_pdate = split('-', $p_date);

    my $dt = new DateTime(
	year => $split_pdate[0],
	month => $split_pdate[1],
	day => $split_pdate[2]
	);

    my @ret_date = ();
    my $dt_tmp = $dt->clone();
    my $dt_loop = $dt->clone();
    
    $dt_loop->subtract(days => 3); #sottraggo 3 giorni
    $dt_tmp->add(days => 3); # add aumenta 3 giorni
    
    while($dt_loop <= $dt_tmp){
	push(@ret_date, grep { str2time($_) == str2time($dt_loop) } @dates);
	$dt_loop->add(days => 1);
    }

    my %seen;
    $seen{$_}++ for @ret_date;
    @ret_date = keys %seen;	#trova le chiavi uniche nell'array
#    @ret_date = grep { ++$seen{$_} < 2 } @ret_date;
    my @hash = ();
    my @time = ();

    for my $i (0..$#ret_date){
	@time = $root->findnodes("//p:prenotante[p:disciplina='".$discipline."' and p:campo='".$campo."' and p:data='".$ret_date[$i]."']/p:ora");
	$hash[$i]{date} = $ret_date[$i];
	@time = $self->$text(@time);
	my $time_str = join(" - ", @time);
	$hash[$i]{time} = $time_str;
    }			  
    return $self->printTable($dt, $campo, $discipline, @hash);
}

sub printTable {
    my ($self, $p_day, $campo, $disciplina, @hash) = @_;
    $p_day->subtract(days => 3);
    my $b_name = $p_day->clone();
    my $builder = $p_day->clone();
    my $class;
    my $ret;
    $class = 'green' unless @hash; # non definito
    $class = 'green' if scalar(@hash) == 0; # definizione hash con 0 elementi

    $ret='<table id="prenotazioni_tbl" summary="">
             <caption><h6>Prenotazioni per la settimana del '.$builder->dmy('-').' campo '.$campo.' '.$disciplina.' </h6></caption>
	     <thead>';
#	       <tr>
#                  <th>ORARIO</th>
$ret.='	      	  <th>'.$b_name->day_name().' '.$builder->day().'</th>';
    for(0..1){
	$ret.=' <th>'.$b_name->add(days=>1)->day_name.' '.$builder->add(days=>1)->day().'</th>';
    }
    $ret.=' <th class="selected">'.$b_name->add(days=>1)->day_name.' '.$builder->add(days=>1)->day().'</th>';
    for(0..2){
	$ret.=' <th>'.$b_name->add(days=>1)->day_name.' '.$builder->add(days=>1)->day().'</th>';
    }
    $ret.=' </tr>
               </thead>
               <tfoot>
               </tfoot>
               <tbody>';

    for my $i(16..23){
	$ret.=' <tr>';
   #  		<th>'.$i.':00</th>';
	my $control = $p_day->clone();
	for(0..6){
	    for my $j (0..$#hash){
		my $d_control = $control->ymd('-');
		if($hash[$j]{date} =~m/$d_control/){
		    if($hash[$j]{time} =~ m/$i:00/){
			$class='red';
#			$ret.= $i.':00';  # per vedere gli orari  
			last; 
		    }
		    else{ $class = 'green';}
		}
		else{ $class = 'green';}
	    }
	    $ret.=' <td class="'.$class.'">'.$i.':00</td>';
	    $control->add(days => 1);
	}
	$ret.= ' </tr>';
    }	
    $ret.=' </tbody>
           </table>';
    return $ret;
}

# estrae i prezzi dei corsi dall' xml e li associa ad un array di hash
# infine richiama la funzione di stampa

sub getPrezziCorsi{
    my $self = shift;
    my $xmldoc = $self->load_xml('../data/corsi.xml');
    my (@corsi_global, %hash, @pr);
    $xmldoc->documentElement->setNamespace("www.corsi.it", "c");
    @corsi_global = $xmldoc->getElementsByTagName('corso');
    
    foreach(@corsi_global){
	@pr = ();
	push(@pr, $self->$get($_, 'mensile'));
	push(@pr, $self->$get($_, 'trimestrale'));
	push(@pr, $self->$get($_, 'semestrale'));
	push(@pr, $self->$get($_, 'annuale'));
	$hash{$self->$get($_, 'nome')} = \@pr;
    }
    
    return $self->printPR2(%hash);
}

# prova CGI table

sub printPR2{
    my $self = shift;
    my (%hash) = @_;
    my $ret = caption(h5('Abbonamenti'));
    $ret.= thead(Tr(th({scope => 'col'}, [qw(Corso Mensile Trimestrale Semestrale Annuale)])));
    $ret.= tfoot();
    $ret.= tbody(join('', map { Tr({scope => 'row'}, td($_), td( [ @{$hash{$_}} ])) } keys %hash));
    $ret = table({id => 'corsi_tbl' , summary => ''}, $ret);
    return $ret;
}

# funzione di stampa della tabella prezzi

sub printTblPrezziCorsi{
    my ($self, $corsi, $prezzi) = @_;
    my ($ret, $class);
    $ret="<table id=\"corsi_tbl\" summary=\"\">
          <caption><h5>Abbonamenti</h5></caption>
	    <thead>
              <tr>
                <th>Corso</th>
                <th>Mensile</th>
                <th>Trimestrale</th>
                <th>Semestrale</th>
                <th>Annuale</th>
              </tr>
            </thead>
            <tfoot>
            </tfoot>
            <tbody>
            ";

    for my $i(0..$#{$corsi}){ # accesso per riferimento, $# indica l'indice massimo presente nell'array, equivale a @-1
	if($i%2){$class='odd';}
	else{$class='';}
	$ret.="<tr class='$class'>
                 <td>$corsi->[$i]</td>
                 ";
	$ret.="<td>$prezzi->[$i]{mensile}</td>\n\t\t".
	    "<td>$prezzi->[$i]{trimestrale}</td>\n\t\t".
	    "<td>$prezzi->[$i]{semestrale}</td>\n\t\t".
	    "<td>$prezzi->[$i]{annuale}</td>\n\t\t";
	$ret.="</tr>\n\t\t";
    }
    $ret.="</tbody>
         </table>";
    return $ret;
}

# stampa tabelle corsi settimanali

sub printTblCorsi{
    my($self, $corsi, $time)=@_;
    my $ret;
    $ret="<table id=\"prenotazioni_tbl\" summary=\"\">
          <caption><h5>Corsi</h5></caption>
	    <thead>
              <tr>
                <th>Corso</th>
                <th>Lunedì</th>
                <th>Martedì</th>
                <th>Mercoledì</th>
                <th>Giovedì</th>
                <th>Venerdì</th>
                <th>Sabato</th>
                <th>Domenica</th>
              </tr>
            </thead>
            <tfoot>
            </tfoot>
            <tbody>
            ";
    for my $i(0..$corsi){
	$ret.="<tr>
                <th>$corsi->[$i]</th>
             ";
	for my $j(0..6){
	    $ret.="<td>$time->[$i]{$j}</td>\n";
	}
	$ret.="</tr>\n";
    }
    $ret.="</tbody>
        </table>";
    return $ret;
}

# prova utilizzando modulo CGI
# piu corto, un solo hash, da rifare prezzicorsi

sub printPR{
    my $self = shift;
    my %hash = @_;
    my $ret;
    $ret = caption(h5('Corsi prova'));
    $ret.= thead(Tr(th({scope => 'col'}, [qw(Corso Lunedì Martedì Mercoledì Giovedì Venerdì Sabato Domenica)])));
    $ret.= tfoot();
    $ret.= tbody(join( '', map { Tr(th({scope => 'row'},$_), td( [ @{$hash{$_}} ])) } sort keys %hash ));
    $ret = table({id => 'prenotazioni_tbl' , summary => ''}, $ret);
    return $ret;
}

sub getOrari{
    my $self = shift;
    my $xmldoc = $self->load_xml('../data/corsi.xml');
    my (@orari_global, %hash, @pr);
    $xmldoc->documentElement->setNamespace("www.corsi.it", "c");
    @orari_global = $xmldoc->getElementsByTagName('corso');

    foreach(@orari_global){
	@pr = ();
	push(@pr, $self->$get($_, 'lun'));
	push(@pr, $self->$get($_, 'mar'));
	push(@pr, $self->$get($_, 'mer'));
	push(@pr, $self->$get($_, 'gio'));
	push(@pr, $self->$get($_, 'ven'));
	push(@pr, $self->$get($_, 'sab'));
	push(@pr, $self->$get($_, 'dom'));
	$hash{$self->$get($_, 'nome')} = \@pr;
    }
    
    $self->printPR(%hash);
}

sub dispatcher {
    my $self = shift;
    my $route = shift;
    my %params = @_;
    my $template = HTML::Template->new(filename => $route.".tmpl");
    foreach(keys %params){
	$template->param($_ => $params{$_});
    }	
    my @loop_news = $self->getNews;
    $template->param(NEWS => \@loop_news);
    HTML::Template->config(utf8 => 1);
    print "Content-Type: text/html\n\n", $template->output;
}

sub is_logged {
    my $self = shift;
    my $session = CGI::Session->load();
    if($session->param("~logged-in")){
	return 1;
    }
    return;
}

1;
