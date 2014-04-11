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

sub checkform{
    my($xmldoc, $parser, $disciplina, $data, $ora)=@_;
    my $root=$xmldoc->getDocumentElement;
    $xmldoc->documentElement->setNamespace("www.prenotazioni.it", "p");
    #controllo se esiste un match (prenotazione gia' presa)
#    my $ret=$root->findnodes("//p:prenotante[p:disciplina='".$disciplina."' and p:data='".$data."' and p:ora='".$ora."']/p:nome");
    my $ret=$root->exists("//p:prenotante[p:disciplina='".$disciplina."' and p:data='".$data."' and p:ora='".$ora."']/p:nome");
    return $ret;
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

    my $dow=$dt->day_of_week;	#giorno della settimana int

    my @sorted_dates = sort {str2time($a) <=> str2time($b)} @dates;

#	print $_,"\n" for @sorted_dates;
    my @ret_date;
    my $dt_tmp=$dt->clone();
    my $dt_loop=$dt->clone();

    $dt_tmp->add(days=>6); # add aumenta i giorni

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

sub print_news{
    $cgi=shift;
    print "\n\t";
    print $cgi->start_div({-id=>'news_container'})."\n\t\t";
    print $cgi->start_div({-id=>'news'})."\n\t\t\t";
    print '<h2>NEWS</h2>
		<ul>
		      <li>NEW1</li>
		      <li>NEW2</li>
		      <li>ew3New3NewNew3New3New3New3NewNew3New3New3NewNew3New3New3</li>
		      <li>New4</li>
		      </ul>';
    print "\n\t\t";
    print $cgi->end_div;
    print "\n\t";
    print $cgi->end_div;
    print "\n";
}

1;
