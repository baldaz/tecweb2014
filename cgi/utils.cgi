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

sub parseXML{		   
    my($xmldoc, $parser)=@_;
#	my @date=$xml->getElementsByTagName('data');
#	my @ore=$xml->getElementsByTagName('ora');
    my $root=$xmldoc->getDocumentElement;
    $xmldoc->documentElement->setNamespace("www.prenotazioni.it", "p");
    my $date=$root->findnodes("//p:prenotante[p:disciplina='Calcetto']/p:data");
#	my $time=$root->findnodes("//p:prenotante[p:disciplina='Calcetto']/p:ora");

#	substr($date, 10, 0)=' ';
    print $date;

}

sub get_week{
    my ($xmldoc, $parser, $p_date)=@_;
    my $root=$xmldoc->getDocumentElement;
    $xmldoc->documentElement->setNamespace("www.prenotazioni.it", "p");
    my @date=$root->findnodes("//p:prenotante[p:disciplina='Calcetto']/p:data");
    my @time=$root->findnodes("//p:prenotante[p:disciplina='Calcetto']/p:ora");

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
    my %fill;

    for my $i (0..$#ret_date){
	@time=$root->findnodes("//p:prenotante[p:disciplina='Calcetto' and p:data='".$ret_date[$i]."']/p:ora");
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
    &print_table($dt);
}

sub print_table{
    my $p_day=shift;
    print '<table summary="">
             <caption>Prenotazioni</caption>
	     <thead>
	       <tr>
                  <th>ORARIO</th>
	      	  <th>'.$p_day->day_name().'</th>';
    for(0..5){
	print '<th>'.$p_day->add(days=>1)->day_name.'</th>';
    }
    print '</tr>
               </thead>
               <tbody>';

    for my $i(16..23){
	print ' <tr>
      		<th>'.$i.':00</th>';
	for(0..6){
	    print '<td class="red"></td>';
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
1;
