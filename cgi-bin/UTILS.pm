#!/usr/bin/perl

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

# protette per uso interno

my $_text = sub {
    my $self = shift;
    my (@data) = @_;
    my @ret = map { $_->textContent } @data;
    return @ret;
};

my $_italian_days = sub {
    my ($self, $start_dt) = @_;
    my %day_names = (
	'Sunday'    => 'Domenica',
	'Monday'    => 'Lunedì',
	'Tuesday'   => 'Martedì',
	'Wednesday' => 'Mercoledì',
	'Thursday'  => 'Giovedì',
	'Friday'    => 'Venerdì',
	'Saturday'  => 'Sabato'
	);
    my @it_days = ();
    push(@it_days, $day_names{$start_dt->day_name()}." ".$start_dt->day());
    push(@it_days, $day_names{$start_dt->add(days => 1)->day_name()}." ".$start_dt->day()) for 0..5;
    return @it_days;
};

# costruisce la tabella delle prenotazioni

my $_table_prenotazioni = sub {
    my ($self, $p_day, $campo, $disciplina, @hash) = @_;
    $p_day->subtract(days => 3);
    my $builder = $p_day->clone();
    my $class;
    my $fill = 'libero';
    my $body;
    $class = 'green' unless @hash; # non definito
    $class = 'green' if scalar(@hash) == 0; # definizione hash con 0 elementi    
    my $table = caption('Prenotazioni per la settimana del '.$builder->dmy('-').' campo '.$campo.' '.$disciplina);
    my @it_days = $self->$_italian_days($builder);   
    for my $i(16..23){
	$body.='<tr>
                 <th scope="row"><time>'.$i.':00</time></th>';
	my $control = $p_day->clone();
	for(0..6){
	    for my $j (0..$#hash){
		my $d_control = $control->ymd('-');
		if($hash[$j]{date} =~m/$d_control/){
		    if($hash[$j]{time} =~ m/$i:00/){
			$class = 'red';
			$fill = 'occupato';
			last; 
		    }
		    else{ $class = 'green'; $fill = 'libero';}
		}
		else{ $class = 'green'; $fill = 'libero';}
	    }
	    $body.=" <td class='$class'>$fill</td>";
	    $control->add(days => 1);
	}
	$body.= ' </tr>';
    }	
    my $wrapped_body = tbody($body);
    $table .= thead(Tr(th({scope => 'col'}, ['ORARIO', @it_days])));
    $table .= $wrapped_body;
    $table = table({class => 'table simple', summary => 'Prenotazione dei campi per la settimana selezionata'}, $table);
    return $table;
};

#costruttore

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

sub check_prenotation {
    my($self, $disciplina, $campo, $data, $ora) = @_;
    $self->load_xml('../data/prenotazioni.xml');
    my $root = $self->load_xml->getDocumentElement;
    my $ret = $root->exists("//prenotante[disciplina='$disciplina' and data='$data' and ora='$ora' and campo='$campo']/nome");
    return $ret;
}

sub _today {
    my $self = shift;
    my $today = DateTime->today->ymd("-");
    my @day = split('-', $today);
    my $dt = DateTime->new(day => $day[2], month => $day[1], year => $day[0]);
    return $dt;
}

sub getNews {
    my $self = shift;
    my $xml = $self->load_xml('../data/news.xml');
    my @news = $xml->findnodes("//new");
    my @loop_news = map {{N_TITLE   => $_->findvalue("titolo"),
	                  N_CONTENT => $_->findvalue("contenuto"),
			  N_DATE    => $_->findvalue("data"),
	                  N_ID      => $_->getAttribute("id")}} @news;
    return @loop_news;
}

# estrae il numero di campi di una data disciplina dal file xml

sub getFields {
    my ($self, $disciplina) = @_;
    my $xml = $self->load_xml('../data/impianti.xml');
#    $xml->documentElement->setNamespace("www.impianti.it","i");
    my $ret = $xml->findvalue("//impianto[disciplina='$disciplina']/campi");
    return $ret;
}

sub getWeek {
    my ($self, $discipline, $campo, $p_date) = @_;
    my $xmldoc = $self->load_xml('../data/prenotazioni.xml');
    my $root = $xmldoc->getDocumentElement;
#    $xmldoc->documentElement->setNamespace("www.prenotazioni.it", "p");
    my @dates = $root->findnodes("//prenotante[disciplina='$discipline' and campo='$campo']/data");

    @dates = $self->$_text(@dates);

    my @split_pdate = split('-', $p_date);

    my $dt = DateTime->new(
	year  => $split_pdate[0],
	month => $split_pdate[1],
	day   => $split_pdate[2]
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
    my @hash = ();
    my @time = ();

    for my $i (0..$#ret_date){
	@time = $root->findnodes("//prenotante[disciplina='$discipline' and campo='$campo' and data='$ret_date[$i]']/ora");
	$hash[$i]{date} = $ret_date[$i];
	@time = $self->$_text(@time);
	$hash[$i]{time} = join(" - ", @time);
    }
    $self->$_table_prenotazioni($dt, $campo, $discipline, @hash);
}

# estrae i prezzi dei corsi dall' xml e li associa ad un array di hash
# infine richiama la funzione di stampa

sub list_prices {
    my $self = shift;
    my $xml = $self->load_xml('../data/corsi.xml');
    my @courses = $xml->findnodes("//corso");
    my @loop_courses = map {{c_name => $_->findvalue("nome"), c_mon => $_->findvalue("mensile"),
			     c_tri => $_->findvalue("trimestrale"), c_sem => $_->findvalue("semestrale"),
			     c_ann => $_->findvalue("annuale")}} @courses;
    return @loop_courses;
}

sub list_scheduling {
    my $self = shift;
    my $xml =$self->load_xml('../data/corsi.xml');
    my @courses = $xml->findnodes("//corso");
    my @loop_courses = map {{c_name => $_->findvalue("nome"), c_lun => $_->findvalue("orari/lun"), 
			     c_mar => $_->findvalue("orari/mar"), c_mer => $_->findvalue("orari/mer"), 
			     c_gio => $_->findvalue("orari/gio"), c_ven => $_->findvalue("orari/ven"),
			     c_sab => $_->findvalue("orari/sab"), c_dom => $_->findvalue("orari/dom")}} @courses;
    return @loop_courses;
}

sub dispatcher {
    my $self = shift;
    my $route = shift;
    my %params = @_;
    my $template = HTML::Template->new(filename => $route.".tmpl", utf8 => 1);
    foreach(keys %params){
	$template->param($_ => $params{$_});
    }	
    my @loop_news = $self->getNews;
    delete $_->{N_ID} foreach(@loop_news);
    $template->param(NEWS => \@loop_news);
    print "Content-Type: text/html\n\n", $template->output;
}

sub dispatch_error {
    my ($self, $code, $desc, $is_logged, $profile) = @_;
    my %params = (
	title    => 'Errore '.$code,
	page     => 'error',
	path     => 'Errore '. $code,
	LOGIN    => $is_logged,
	USER     => $profile,
	err_code => $code,
	err_desc => $desc
	);
    $self->dispatcher('error', %params);
}

sub select_field {
    my ($self, $disciplina, $data, $ora) = @_;
    my $xml = $self->load_xml('../data/prenotazioni.xml');
    my $root = $xml->getDocumentElement;
    my @fields = $root->findnodes("//prenotante[disciplina='$disciplina' and data='$data' and ora='$ora']/campo");
    @fields = $self->$_text(@fields);
    my $count = $self->getFields($disciplina);
    my %b_fields = map {$_ => 1} @fields;
    my @f_fields = grep {not $b_fields{$_}} 1..$count;
    my $ret;
    if(@f_fields){
	foreach my $field(@f_fields){
	    if(!$self->check_prenotation($disciplina, $field, $data, $ora)){
		$ret = $field;
		last;
	    }
	}
    }
    else{ $ret = -1; }
    return $ret;
}

1;
