#!/usr/bin/perl -w

package UTILS::Admin;
use parent 'UTILS';

$ENV{HTML_TEMPLATE_ROOT} = "../public_html/templates/admin";

my $get_path = sub {		    # da spostare su UTILS, e fare inheritance
    my $self = shift;
    return "../data/".shift.".xml";
};

sub new { bless {}, shift }

sub init {
    my ($self, $session, $cgi) = @_;
    if ( $session->param("~logged-in") ) {
	$session->expire(120);
	return 1;  # se già loggato posso uscire
    }
    
    my $user = $cgi->param("username") or return;
    my $passwd = $cgi->param("passwd") or return;
    
    if (my $profile = $self->load_profile($user, $passwd)){
	$session->param("~profile", $profile);
	$session->param("~logged-in", 1);
	$session->clear(["~login-trials"]);
	$session->expire(720);
	return 1;
    }

    # a questo punto le credenziali sono errate

    my $trials = $session->param("~login-trials") || 0;
    return $session->param("~login-trials", ++$trials);
}

sub load_profile {
    my ($self, $user, $passwd) = @_;
    my $profiles_xml = $self->load_xml('../data/profili.xml');
    my $root = $profiles_xml->getDocumentElement;
    $profiles_xml->documentElement->setNamespace("www.profili.it", "p");
				# controllo se esiste un match (profilo esistente) 
    my $ret = $root->exists("//p:profilo[p:username='$user' and p:password='$passwd']");
    if($ret){
	return $user;
    }
    
    return undef;
}

sub add_resource {
    my $self = shift;
    my %stash = @_;
    my ($suffix, $element, $action, $from) = split (/:/, $stash{'namespace'});
    my $path = $self->$get_path($suffix);
    my $parser = XML::LibXML->new();
    my $xml = $parser->parse_file($path);
    my $root = $xml->getDocumentElement();
#    $xml->documentElement->setNamespace("www.$suffix.it","n");
    my $id = $stash{'id'};
    delete $stash{'namespace'};
    delete $stash{'formfor'};
    delete $stash{'id'};
    my $ret = "\t<$element id='$id'>";
    $ret.= "\n\t\t<$_>$stash{$_}</$_>" foreach keys %stash;
    $ret.= "\n\t</$element>\n";
    my $token = $xml->getElementsByTagName($suffix)->[0];
    my $chunk = $parser->parse_balanced_chunk($ret);
    if($action eq 'add'){
	$token->appendChild($chunk); # fare un $token->lastChild ed estrarre l'id, inserire ++id nel nuovo nodo
    }
    elsif($action eq 'edit'){
	if($root->exists($element."[\@id=$id]")){
	    $token = $root->findnodes($element."[\@id=$id]")->get_node(1);
	    $token->replaceChild($chunk, $token) || die $!;
	}
	else { die $!; }	# condizione eliminabile
    }
    elsif($action eq 'delete'){
	$token = $root->findnodes($element."[\@id=$id]")->get_node(1);
	$token->unbindNode();
    }
    else { die $!; }		# lanciare errore
    open(OUT, ">$path") || die "error $!";
    print OUT $xml->toString || die $!; 
    close OUT;
#    print "Content-type: text/html\n\n";
    print CGI::header(-location => "admin.cgi?screen=$from");
}

sub dispatch {
    my $self = shift;
    my $route = shift;
    my %params = @_;
    my $template = HTML::Template->new(filename => $route.".tmpl");
    foreach(keys %params){
	$template->param($_ => $params{$_});
    }	
    HTML::Template->config(utf8 => 1);
    print "Content-Type: text/html\n\n", $template->output;
}

sub list_news {
    my $self = shift;
    my @list = $self->getNews();
    return @list;
}

sub list_courses {
    my $self = shift;
    my $xml = $self->load_xml('../data/corsi.xml');
#    $xml->documentElement->setNamespace("www.news.it","n");
    my @courses = $xml->findnodes("//corso");
    my @loop_courses = map {{C_NAME => $_->findvalue("nome"), MONTHLY => $_->findvalue("mensile"),
	                     TRIMESTRAL => $_->findvalue("trimestrale"), SEMESTRAL => $_->findvalue("semestrale"),
	                     ANNUAL => $_->findvalue("annuale")}} @courses;
    return @loop_courses;
}

sub get_ndata {
    my ($self, $id) = @_;
    my $xml = $self->load_xml('../data/news.xml');
    my %data = ();
    if($xml->getDocumentElement->exists("//new[\@id=$id]")){	
	$data{n_title} = $xml->findvalue("//new[\@id='$id']/titolo");
	$data{n_content} = $xml->findvalue("//new[\@id='$id']/contenuto");
	$data{n_date} = $xml->findvalue("//new[\@id='$id']/data");
    }
    else {
	$data{not_found} = 1;
    }
    return %data;
}

1;
