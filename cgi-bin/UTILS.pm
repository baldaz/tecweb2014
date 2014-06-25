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
use Net::SMTP;
use Encode;

$ENV{HTML_TEMPLATE_ROOT} = "../public_html/templates";

# protette

my $_get = sub {
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

my $_table_prenotazioni = sub {
    my ($self, $p_day, $campo, $disciplina, @hash) = @_;
    $p_day->subtract(days => 3);
    my $builder = $p_day->clone();
    my $class;
    my $fill = 'libero';
    my $body;
    $class = 'green' unless @hash; # non definito
    $class = 'green' if scalar(@hash) == 0; # definizione hash con 0 elementi    
    my $table = caption(h6('Prenotazioni per la settimana del '.$builder->dmy('-').' campo '.$campo.' '.$disciplina));
    my @it_days = $self->$_italian_days($builder);   
    for my $i(16..23){
	$body.='<tr>
                 <th scope="row">'.$i.':00 </th>';
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
	    $body.=" <td class=$class>$fill</td>";
	    $control->add(days => 1);
	}
	$body.= ' </tr>';
    }	
    my $wrapped_body = tbody($body);
    $table .= thead(Tr(th({scope => 'col'}, ['ORARIO', @it_days])));
    $table .= tfoot();
    $table .= $wrapped_body;
    $table = table({class => 'table simple', summary => ''}, $table);
    return $table;
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

sub _today {
    my $self = shift;
    my $dt = DateTime->today->ymd("-");
    return $dt;
}

sub getNews {
    my $self = shift;
    my $xml = $self->load_xml('../data/news.xml');
#    $xml->documentElement->setNamespace("www.news.it","n");
#    my $root = $xml->getDocumentElement;
    my @news = $xml->findnodes("//new");
    my @loop_news = map {{N_TITLE   => encode('utf8', $_->findvalue("titolo")),
	                  N_CONTENT => encode('utf8', $_->findvalue("contenuto")),
			  N_DATE    => encode('utf8', $_->findvalue("data")),
	                  N_ID      => encode('utf8', $_->getAttribute("id"))}} @news;
    return @loop_news;
}

# estrae il numero di campi di una data disciplina dal file xml

sub getFields {
    my ($self, $disciplina) = @_;
    my $xml = $self->load_xml('../data/impianti.xml');
    $xml->documentElement->setNamespace("www.impianti.it","i");
    my $ret = $xml->findvalue("//i:impianto[i:disciplina='$disciplina']/i:campi");
    return $ret;
}

# estrae il perscorsi delle immagini degli impianti dal file xml
# deprecabile
sub getImg {
    my $self = shift;
    my $xml = $self->load_xml('../data/impianti.xml');
    $xml->documentElement->setNamespace("www.impianti.it","i");
    my @ret_img = $xml->findnodes("//i:impianto/i:src");
    return $self->$_text(@ret_img);
}

# estrae la descrizione di una data sezione dal file xml
 
sub getDesc {
    my ($self, $nome) = @_;
    my $xml = $self->load_xml('../data/sezioni.xml');
    $xml->documentElement->setNamespace("www.sezioni.it","s");
    my $ret_desc = $xml->findvalue("//s:sezione[\@nome='$nome']/s:contenuto");
#    @ret_desc = $self->_$text(@ret_desc);
#    my $ret_descr.= join( '', @ret_desc );
}

sub getWeek {
    my ($self, $discipline, $campo, $p_date) = @_;
    my $xmldoc = $self->load_xml('../data/prenotazioni.xml');
    my $root = $xmldoc->getDocumentElement;
    $xmldoc->documentElement->setNamespace("www.prenotazioni.it", "p");
    my @dates = $root->findnodes("//p:prenotante[p:disciplina='$discipline' and p:campo='$campo']/p:data");

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
#    @ret_date = grep { ++$seen{$_} < 2 } @ret_date;
    my @hash = ();
    my @time = ();

    for my $i (0..$#ret_date){
	@time = $root->findnodes("//p:prenotante[p:disciplina='$discipline' and p:campo='$campo' and p:data='$ret_date[$i]']/p:ora");
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
#    $xml->documentElement->setNamespace("www.news.it","n");
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
    my $template = HTML::Template->new(filename => $route.".tmpl");
    foreach(keys %params){
	$template->param($_ => $params{$_});
    }	
    my @loop_news = $self->getNews;
    foreach(@loop_news){
	delete $_->{N_ID};
    }
    $template->param(NEWS => \@loop_news);
    HTML::Template->config(utf8 => 1);
    print "Content-Type: text/html\n\n", $template->output;
}

sub select_field {
    my ($self, $disciplina, $data, $ora) = @_;
    my $xml = $self->load_xml('../data/prenotazioni.xml');
    my $root = $xml->getDocumentElement;
    $xml->documentElement->setNamespace("www.prenotazioni.it", "p");
    my @fields = $root->findnodes("//p:prenotante[p:disciplina='$disciplina' and p:data='$data' and p:ora='$ora']/p:campo");
    @fields = $self->$_text(@fields);
    my $count = $self->getFields($disciplina);
    my %b_fields = map {$_ => 1} @fields;
    my @f_fields = grep {not $b_fields{$_}} 1..$count;
    my $ret;
    if(@f_fields){
	foreach my $field(@f_fields){
	    if(!$self->checkform($disciplina, $field, $data, $ora)){
		$ret = $field;
		last;
	    }
	}
    }
    else{ $ret = -1; }
    return $ret;
}

sub send_email {
    my ($self, $subject, $from, $to, $message) = @_;
    my $dt = DateTime->now;
    my $smtp = Net::SMTP->new('smtp.studenti.math.unipd.it',
			      Hello   => 'studenti.math.unipd.it',
			      Timeout => 30,
			      Debug   => 1,
	);
    $smtp->datasend("Date: ".DateTime::Format::Mail->format_datetime( $dt )."\n");
    $smtp->datasend("Subject: $subject\n");
    $smtp->datasend("From: $from\n");
    $smtp->datasend("To: $to\n\n");
    $smtp->datasend($message);
    $smtp->dataend();
    $smtp->quit;
}

1;
