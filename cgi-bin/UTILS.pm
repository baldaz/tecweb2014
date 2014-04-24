#!/usr/bin/perl -w

package UTILS;

use strict;
use warnings;
use XML::LibXML;
use CGI qw(:standard);
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use CGI::Session;
use DateTime;
use Date::Parse;
use feature 'switch';

sub init{
    my ($session, $cgi, $profiles_xml) = @_;
    if ( $session->param("~logged-in") ) {
	return 1;  # se già loggato posso uscire
    }
    
    my $user = $cgi->param("username") or return;
    my $passwd=$cgi->param("passwd") or return;
    
    if (my $profile=load_profile($user, $passwd, $profiles_xml)){
	$session->param("~profile", $profile);
	$session->param("~logged-in", 1);
	$session->clear(["~login-trials"]);
	$session->expire("~logged-in" => '+4m');
	return 1;
    }

    # a questo punto le credenziali sono errate

    my $trials = $session->param("~login-trials") || 0;
    return $session->param("~login-trials", ++$trials);
}

sub load_profile {
    my ($user, $passwd, $profiles_xml) = @_;
    my $root=$profiles_xml->getDocumentElement;
    $profiles_xml->documentElement->setNamespace("www.profili.it", "p");
				# controllo se esiste un match (profilo esistente) 
    my $ret=$root->exists("//p:profilo[p:username='$user' and p:password='$passwd']");
    if($ret){
	my $p_mask="x".length($passwd);
	return {username=>$user, password=>$p_mask};
    }
    
    return undef;
}

sub footer{
    my $page=shift;
    print $page->div({id=>'footer'},
		     "\n",
		     $page->p("\n",
			      $page->span({lang=>"en"}, 'Copyright'), '© 2014 CiccipanzeSulWeb',
			      "\n",
			      $page->a({href=>"http://validator.w3.org/check?uri=referer"},
				       "\n",
				       $page->img({-src=>"http://www.w3.org/Icons/valid-xhtml10", -alt=>"Valid XHTML 1.0 Strict",
						   -height=>"31", -width=>"88"}),
				       "\n",
			      ),
			      "\n",
		     ),
		     "\n",
	),
	"\n",	
	$page->end_div;
}

# loader xml globale

sub loadXml{
    my $path=shift;
    my $parser=XML::LibXML->new("1.0", "UTF-8");
    my $ret=$parser->parse_file($path);
    return $ret;
}

# controllo prenotazione su file xml

sub checkform{
    my($xmldoc, $disciplina, $campo, $data, $ora)=@_;
    my $root=$xmldoc->getDocumentElement;
    $xmldoc->documentElement->setNamespace("www.prenotazioni.it", "p");
    #controllo se esiste un match (prenotazione gia' presa)
    my $ret=$root->exists("//p:prenotante[p:disciplina='$disciplina' and p:data='$data' and p:ora='$ora' and p:campo='$campo']/p:nome");
    return $ret;
}

# controllo numero telefonico

sub check_tel{
    my $number=shift;
    if($number=~/^(\d)+$/){
	return 0;
    }
    else{ return 1;}
}

# estrae il contenuto di un nodo, analogo a text(), ma piu utile nei casi di html e CDATA nel file XML

sub toText{
    my (@data)=@_;
    my @ret;
    for(@data){
	push(@ret ,$_->textContent);
    }
    return @ret;
}

# estrae le news dal file xml

sub loadNews{
    my $xml=shift;
    $xml->documentElement->setNamespace("www.prenotazioni.it","p");
    my @titles=$xml->findnodes("//p:new/p:titolo");
    @titles=toText(@titles);
    my @contents=$xml->findnodes("//p:new/p:contenuto");
    @contents=toText(@contents);
    return (\@titles, \@contents);
}

sub getNews{
    my $xml=shift;
    my ($news_title, $news_content)=&loadNews($xml);     # genero le news da xml
    my @loop_news=();

# scorro i risultati dell'estrazione e li inserisco in un hash

    while($a=shift @$news_title and $b=shift @$news_content){
	my %row_data;
	$row_data{N_TITLE}=Encode::encode('utf-8',$a); # encoding dei me coioni
	$row_data{N_CONTENT}=Encode::encode('utf-8',$b); # encoding dei me coioni
	push(@loop_news, \%row_data);
    }
    return @loop_news;
}

# estrae il numero di campi di una data disciplina dal file xml

sub getFields{
    my ($xml, $disciplina)=@_;
    $xml->documentElement->setNamespace("www.impianti.it","i");
    my @ret_n=$xml->findnodes("//i:impianto[i:disciplina='$disciplina']/i:campi");
    @ret_n=toText(@ret_n);
    return $ret_n[0];
}

# estrae il perscorsi delle immagini degli impianti dal file xml

sub getImg{
    my $xml=shift;
    $xml->documentElement->setNamespace("www.impianti.it","i");
    my @ret_img=$xml->findnodes("//i:impianto/i:src/text()");
    return @ret_img;
}

# estrae la descrizione di una data sezione dal file xml
 
sub getDesc{
    my ($xml, $nome)=@_;
    $xml->documentElement->setNamespace("www.sezioni.it","s");
    my @ret_desc=$xml->findnodes("//s:sezione[\@nome='$nome']/s:contenuto");
    @ret_desc=toText(@ret_desc);
    my $ret_descr;
    foreach(@ret_desc){
	$ret_descr.=$_;
    }
    return $ret_descr;
}

# funzione di modifica generica

sub update{
    my($filter, $old_data, $new_data)=@_;
    my $xml;
    given($filter){
	when(/news/){
	    $xml=loadXml('..data/prenotazioni.xml');
	}
	when(/corso/){
	    $xml=loadXml('..data/corsi.xml');
	}
	when(/impianto/){
	    $xml=loadXml('..data/impianti.xml');
	}
	when(/contatto/){
	}
	when(/prenotazione/){
	    $xml=loadXml('..data/prenotazioni.xml');
	}
	default{
	}
    }
}

#################################################
#                     #                         #
# TESTING SUBROUTINES # JUST FOR HTML::TEMPLATE #
#                     #                         #
#################################################
#                                               #
#            SO GOOD FOR 2 BUCKS!               #
#                                               #
#################################################

sub getWeek{
    my ($xmldoc, $discipline, $campo, $p_date)=@_;
    my $root=$xmldoc->getDocumentElement;
    $xmldoc->documentElement->setNamespace("www.prenotazioni.it", "p");
    my @dates=$root->findnodes("//p:prenotante[p:disciplina='".$discipline."' and p:campo='".$campo."']/p:data");

    @dates=toText(@dates);

    my @split_pdate=split('-', $p_date);

    my $dt=new DateTime(
	year=>$split_pdate[0],
	month=>$split_pdate[1],
	day=>$split_pdate[2]
	);

    my @ret_date;
    my $dt_tmp=$dt->clone();
    my $dt_loop=$dt->clone();
    
    $dt_loop->subtract(days=>3); #sottraggo 3 giorni
    $dt_tmp->add(days=>3); # add aumenta 3 giorni

    while($dt_loop <= $dt_tmp){
	for(@dates){
	    if(str2time($_) == str2time($dt_loop)){
		push(@ret_date, $_);
	    }
	}
	$dt_loop->add(days=>1);
    }

    my %seen;
    $seen{$_}++ for @ret_date;
    @ret_date=keys %seen;	#trova le chiavi uniche nell'array

    my @hash;
    my @time;

    for my $i (0..$#ret_date){
	@time=$root->findnodes("//p:prenotante[p:disciplina='".$discipline."' and p:campo='".$campo."' and p:data='".$ret_date[$i]."']/p:ora");
	$hash[$i]{date}=$ret_date[$i];
	@time=toText(@time);
	my $time_str=join(" - ", @time);
	$hash[$i]{time}=$time_str;
    }			  

#    for my $i (0..$#hash){
#	print "$i is { ";
#	for my $role (keys%{$hash[$i]}){
#	    print "$role=$hash[$i]{$role}";
#	}
#	print "}<br />";
 #   }
    
    return &printTable($dt, $campo, $discipline, @hash);
}

sub printTable{
    my ($p_day, $campo, $disciplina, @hash)=@_;
    my $b_name=$p_day->clone();
    $p_day->subtract(days=>3);
    my $builder=$p_day->clone();
    my $class;
    my $ret;
    $class='green' unless @hash; # non definito
    $class='green' if scalar(@hash)==0; # definizione hash con 0 elementi

    $ret='<table id="prenotazioni_tbl" summary="">
             <caption><h6>Prenotazioni per la settimana del '.$builder->dmy('-').' campo '.$campo.' '.$disciplina.' </h6></caption>
	     <thead>
	       <tr>
                  <th>ORARIO</th>
	      	  <th>'.$b_name->day_name().' '.$builder->day().'</th>';
    for(0..1){
	$ret.=' <th>'.$b_name->add(days=>1)->day_name.' '.$builder->add(days=>1)->day().'</th>';
    }
    $ret.=' <th class="selected">'.$b_name->add(days=>1)->day_name.' '.$builder->add(days=>1)->day().'</th>';
    for(0..2){
	$ret.=' <th>'.$b_name->add(days=>1)->day_name.' '.$builder->add(days=>1)->day().'</th>';
    }
    $ret.=' </tr>
               <tfoot>
               </tfoot>
               </thead>
               <tbody>';

    for my $i(16..23){
	$ret.=' <tr>
      		<th>'.$i.':00</th>';
	my $control=$p_day->clone();
	for(0..6){
	    for my $j (0..$#hash){
		my $d_control=$control->ymd('-');
		if($hash[$j]{date}=~m/$d_control/){
		    if($hash[$j]{time}=~ m/$i:00/){
			$class='red';
#			$ret.= $i.':00';  # per vedere gli orari  
			last; 
		    }
		    else{ $class='green';}
		}
		else{ $class='green';}
	    }
	    $ret.=' <td class="'.$class.'">'.$i.':00</td>';
	    $control->add(days=>1);
	}
	$ret.= ' </tr>';
    }	
    $ret.=' </tbody>
           </table>';
    return $ret;
}

# ausiliaria ottenere valore nodo

sub get {
  my ($node, $name) = @_;

  my $value = "(Element $name not found)";
  my @targets = $node->getElementsByTagName($name);

  if (@targets) {
    my $target = $targets[0];
    $value = $target->textContent;
  }

  return $value;
}

# estrae i prezzi dei corsi dall' xml e li associa ad un array di hash
# infine richiama la funzione di stampa

sub getPrezziCorsi{
    my $xmldoc=shift;
    my (@corsi, @corsi_global, @prezzi, $i);
    my $root=$xmldoc->getDocumentElement;
    $xmldoc->documentElement->setNamespace("www.corsi.it", "c");
    @corsi_global=$xmldoc->getElementsByTagName('corso');
    $i=0;
    
    for my $item(@corsi_global){
	$corsi[$i]=&get($item, 'nome');
	$prezzi[$i]{mensile}=&get($item, 'mensile');
	$prezzi[$i]{trimestrale}=&get($item, 'trimestrale');
	$prezzi[$i]{semestrale}=&get($item, 'semestrale');
	$prezzi[$i]{annuale}=&get($item, 'annuale');
	$i++;
    }

    return &printTblPrezziCorsi(\@corsi, \@prezzi); # 2 array bisogna usare i riferimenti
}

# funzione di stampa della tabella prezzi

sub printTblPrezziCorsi{
    my ($corsi, $prezzi)=@_;
    my ($ret,$class);
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
    my($corsi, $time)=@_;
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
# piu corto

sub printPR{
   # use CGI qw(:standard);
    my $cgi=CGI->new();
    my $ret;
    my %hash = (
	"Yoga" => ["12:00 - 14:00", "", "", "12:00-14:00", "", "", ""],
	"Fit Boxe" => ["16:00 - 18:00", "", "14:00-16:00", "12:00-14:00", "", "", ""],
	"Cross Fit" => ["","","18:00 - 20:00", "21:00 - 23:00", "", "","14:00 - 16:00"], 
	);
    
    $ret="<table id=\"prenotazioni_tbl\" summary=\"\">
          <caption><h5>Corsi</h5></caption>";
    $ret.=Tr(th [qw(Corso Lunedì Martedì Mercoledì Giovedì Venerdì Sabato Domenica)]);
    for my $k (sort keys %hash) {
	$ret.= Tr(th($k), td( [ @{$hash{$k}} ] ));
    }
    $ret.="</table>";
    return $ret;
}
 
1;
