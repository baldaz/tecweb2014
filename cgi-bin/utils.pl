#!/usr/bin/perl -w

use DateTime;
use Date::Parse;

sub init{
    my ($page,$title)=@_;
    print $page->header(-charset=>"UTF-8"),
    $page->start_html(	-meta=>{"content"=>"width=device-width"},
			-title=>$title,
			-dtd=>['-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'],
			-style=>[{-src=>'../css/style.css', -media=>'only screen and (min-width: 768px)'},
				 {-src=>'../css/mobile.css', -media=>'only screen and (max-width: 480px)'},
				 {-src=>'../css/tablet.css', -media=>'only screen and (min-width: 481px) and (max-width: 767px)'}],
			-lang=>it
	);
}

sub footer{
    my $page=shift;
    print $page->div({id=>'footer'},
		     "\n",
		     $page->p("\n",
			      $page->span({lang=>en}, 'Copyright'), '© 2014 CiccipanzeSulWeb',
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

sub get_week{
    my ($xmldoc, $parser, $discipline, $p_date)=@_;
    my $root=$xmldoc->getDocumentElement;
    $xmldoc->documentElement->setNamespace("www.prenotazioni.it", "p");
    my @date=$root->findnodes("//p:prenotante[p:disciplina='".$discipline."']/p:data");
    my @time=$root->findnodes("//p:prenotante[p:disciplina='".$discipline."']/p:ora");

    my @dates=toText(@date);

    my @split_pdate=split('-', $p_date);

    my $dt=new DateTime(
	year=>$split_pdate[0],
	month=>$split_pdate[1],
	day=>$split_pdate[2]
	);

#    my $dow=$dt->day_of_week;	#giorno della settimana int

    my @sorted_dates = sort {str2time($a) <=> str2time($b)} @dates;

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
	@time=$root->findnodes("//p:prenotante[p:disciplina='".$discipline."' and p:data='".$ret_date[$i]."']/p:ora");
	$hash[$i]{date}=$ret_date[$i];
	my @txt_time=toText(@time);
	my $time_str=join(" - ", @txt_time);
#	push @{$hash[$i]{time}}, $_ foreach @txt_time;
	$hash[$i]{time}=$time_str;
#	push(@hash, @{$fill});	# considerare $hash[$i]{date}=$_
    }			  # e push @{$hash[$i]{time}}, $_ foreach @gh;
    # NO, per inserire array come chiavi di un hash serve una libreria, accetta solo stringhe

    for my $i (0..$#hash){
	print "$i is { ";
	for my $role (keys%{$hash[$i]}){
	    print "$role=$hash[$i]{$role} ";
	}
	print "}<br />";
    }
    &print_table($dt, @hash);
}

sub print_table{
    my ($p_day, @hash)=@_;
    $p_day->subtract(days=>3);
    my $builder=$p_day->clone();
    my $class;
    $class='green' if not defined(@hash);
    print '<table summary="">
             <caption>Prenotazioni</caption>
	     <thead>
	       <tr>
                  <th>ORARIO</th>
	      	  <th>'.$builder->day_name()." ".$builder->day().'</th>';
    for(0..1){
	print '<th>'.$builder->add(days=>1)->day_name." ".$builder->day().'</th>';
    }
    print '<th class="selected">'.$builder->add(days=>1)->day_name." ".$builder->day().'</th>';
    for(0..2){
	print '<th>'.$builder->add(days=>1)->day_name." ".$builder->day().'</th>';
    }
    print '</tr>
               </thead>
               <tbody>';

    for my $i(16..23){
	print ' <tr>
      		<th>'.$i.':00</th>';
	my $control=$p_day->clone();
	for(0..6){
	    for my $j (0..$#hash){
		#	for(keys%{$hash[$j]}){
		my $d_control=substr $control, 0, 10;
		if($hash[$j]{date}=~ m/$d_control/){
		    if($hash[$j]{time}=~ m/$i:00/){
			$class='red';
			print $i.':00';
			last; 
		    }
		    else{ $class='green';}
		}
		else{ $class='green';}
		#	}
	    }
	    print '<td class="'.$class.'"></td>';
	    $control->add(days=>1);
	}
	print '</tr>';
    }	
    print '</tbody>
           </table>';
}

sub toText{
    my @data=@_;
    my @ret;
    for(@data){
	push(@ret ,$_->textContent);
    }
    return @ret;
}

sub get_news{
    my($xml, $parser)=@_;
    $xml->documentElement->setNamespace("www.prenotazioni.it","p");
    my @titles=$xml->findnodes("//p:new/p:titolo");
    @titles=toText(@titles);
    my @contents=$xml->findnodes("//p:new/p:contenuto");
    @contents=toText(@contents);
    return (\@titles, \@contents);
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
    my @time=$root->findnodes("//p:prenotante[p:disciplina='".$discipline."' and p:campo='".$campo."']/p:ora");

    my @dates=toText(@date);

    my @split_pdate=split('-', $p_date);

    my $dt=new DateTime(
	year=>$split_pdate[0],
	month=>$split_pdate[1],
	day=>$split_pdate[2]
	);
    my @sorted_dates = sort {str2time($a) <=> str2time($b)} @dates;

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
#	push @{$hash[$i]{time}}, $_ foreach @txt_time;
	$hash[$i]{time}=$time_str;
#	push(@hash, @{$fill});	# considerare $hash[$i]{date}=$_
    }			  # e push @{$hash[$i]{time}}, $_ foreach @gh;
    # NO, per inserire array come chiavi di un hash serve una libreria, accetta solo stringhe

    for my $i (0..$#hash){
	print "$i is { ";
	for my $role (keys%{$hash[$i]}){
	    print "$role=$hash[$i]{$role}";
	}
	print "}<br />";
    }
    return &printTable($dt, $campo, @hash);
}

sub printTable{
    my ($p_day, $campo, @hash)=@_;
    $p_day->subtract(days=>3);
    my $builder=$p_day->clone();
    my $class;
    my $ret;
    $class='green' if not defined(@hash);

    $ret='<input type="number" id="field" name="field" min="1" max="3" value="1" onchange="reload_table()">';
    $ret.='<table summary="">
             <caption>Prenotazioni per il campo '.$campo.' </caption>
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
		#	for(keys%{$hash[$j]}){
		my $d_control=substr $control, 0, 10;
		if($hash[$j]{date}=~ m/$d_control/){
		    if($hash[$j]{time}=~ m/$i:00/){
			$class='red';
			$ret.= $i.':00';
			last; 
		    }
		    else{ $class='green';}
		}
		else{ $class='green';}
		#	}
	    }
	    $ret.=' <td class="'.$class.'"></td>';
	    $control->add(days=>1);
	}
	$ret.= ' </tr>';
    }	
    $ret.=' </tbody>
           </table>';
    return $ret;
}

1;
