#!/usr/bin/perl -w

use DateTime;
use Date::Parse;

sub init{
    my ($session, $cgi, $profiles_xml) = @_;
    if ( $session->param("~logged-in") ) {
	print "logg";
	return 1;  # se già loggato posso uscire
    }
    
    my $user = $cgi->param("username") or return;
    my $passwd=$cgi->param("passwd") or return;
    
    if (my $profile=load_profile($user, $passwd, $profiles_xml)){
	$session->param("~profile", $profile);
	$session->param("~logged-in", 1);
	$session->clear(["~login-trials"]);
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
	print $user;
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
    my($xmldoc, $parser, $disciplina, $campo, $data, $ora)=@_;
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
    my @data=@_;
    my @ret;
    for(@data){
	push(@ret ,$_->textContent);
    }
    return @ret;
}

# estrae le news dal file xml

sub get_news{
    my($xml, $parser)=@_;
    $xml->documentElement->setNamespace("www.prenotazioni.it","p");
    my @titles=$xml->findnodes("//p:new/p:titolo");
    @titles=toText(@titles);
    my @contents=$xml->findnodes("//p:new/p:contenuto");
    @contents=toText(@contents);
    return (\@titles, \@contents);
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
    my ($xmldoc, $parser, $discipline, $campo, $p_date)=@_;
    my $root=$xmldoc->getDocumentElement;
    $xmldoc->documentElement->setNamespace("www.prenotazioni.it", "p");
    my @date=$root->findnodes("//p:prenotante[p:disciplina='".$discipline."' and p:campo='".$campo."']/p:data");

    my @dates=toText(@date);

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
	my @txt_time=toText(@time);
	my $time_str=join(" - ", @txt_time);
	$hash[$i]{time}=$time_str;
    }			  

#    for my $i (0..$#hash){
#	print "$i is { ";
#	for my $role (keys%{$hash[$i]}){
#	    print "$role=$hash[$i]{$role}";
#	}
#	print "}<br />";
 #   }
    return &printTable($dt, $campo, @hash);
}

sub printTable{
    my ($p_day, $campo, @hash)=@_;
    $p_day->subtract(days=>3);
    my $builder=$p_day->clone();
    my $class;
    my $ret;
    $class='green' unless @hash; # non definito
    $class='green' if scalar(@hash)==0; # definizione hash con 0 elementi

    $ret='<table id="prenotazioni_tbl" summary="">
             <caption><h3>Prenotazioni per il campo '.$campo.' </h3></caption>
	     <thead>
	       <tr>
                  <th>ORARIO</th>
	      	  <th>'.$builder->day_name().' '.$builder->day().'</th>';
    for(0..1){
	$ret.=' <th>'.$builder->add(days=>1)->day_name.' '.$builder->day().'</th>';
    }
    $ret.=' <th class="selected">'.$builder->add(days=>1)->day_name.' '.$builder->day().'</th>';
    for(0..2){
	$ret.=' <th>'.$builder->add(days=>1)->day_name.' '.$builder->day().'</th>';
    }
    $ret.=' </tr>
               </thead>
               <tbody>';

    for my $i(16..23){
	$ret.=' <tr>
      		<th>'.$i.':00</th>';
	my $control=$p_day->clone();
	for(0..6){
	    for my $j (0..$#hash){
		my $d_control=substr $control, 0, 10;
		if($hash[$j]{date}=~ m/$d_control/){
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

sub getCorsi{
    my $xmldoc=shift;
    my @corsi;
    my @prezzi;
    my $root=$xmldoc->getDocumentElement;
    $xmldoc->documentElement->setNamespace("www.corsi.it", "c");
    my @corsi_global=$xmldoc->getElementsByTagName('corso');
    my $i=0;
    
    for my $item(@corsi_global){
	$corsi[$i]=&get($item, 'nome');
	$prezzi[$i]{mensile}=&get($item, 'mensile');
	$prezzi[$i]{trimestrale}=&get($item, 'trimestrale');
	$prezzi[$i]{semestrale}=&get($item, 'semestrale');
	$prezzi[$i]{annuale}=&get($item, 'annuale');
	$i++;
    }

    return &printTblCorsi(\@corsi, \@prezzi); # 2 array bisogna usare i riferimenti
}

sub printTblCorsi{
    my ($corsi, $prezzi)=@_;
    my $ret;
    $ret="<table id=\"corsi_tbl\">
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

    for my $i(0..scalar(@{$corsi})){ # accesso per riferimento
	$ret.="<tr>
                 <td>$corsi->[$i]</td>
                 ";
	$ret.="<td>$prezzi->[$i]{mensile}</td>".
	    "<td>$prezzi->[$i]{trimestrale}</td>".
	    "<td>$prezzi->[$i]{semestrale}</td>".
	    "<td>$prezzi->[$i]{annuale}</td>";
	$ret.="</tr>";
    }
    $ret.="</tbody>
         </table>";
    return $ret;
}
1;
