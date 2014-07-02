#!/usr/bin/perl -w

package UTILS::Admin;
use parent 'UTILS';

$ENV{HTML_TEMPLATE_ROOT} = "../public_html/templates/admin";

my $_get_path = sub {		    # da spostare su UTILS, e fare inheritance
    my $self = shift;
    return "../data/".shift.".xml";
};

my $_get_last_id = sub {
    my ($self, $node, $node_name) = @_;
    my $root = $node->getDocumentElement();
    my $id = $root->findnodes($node_name."[last()]/\@id")->[0];
    return $id->textContent if defined($id);
    return 0;
};

my $_build_node = sub {
    my $self = shift;
    my $action = shift;
    my $element = shift;
    my $id = shift;
    $id += 1 if($action eq 'add');
    my %tag = @_;
    my $node = "\t<$element id='$id'>";
    if($element eq 'corso'){
	$node .= "\n\t\t<nome>$tag{nome}</nome>";
	$node .= "\n\t\t<mensile>$tag{mensile}</mensile>";
	$node .= "\n\t\t<trimestrale>$tag{trimestrale}</trimestrale>";
	$node .= "\n\t\t<semestrale>$tag{semestrale}</semestrale>";
	$node .= "\n\t\t<annuale>$tag{annuale}</annuale>";
	$node .= "\n\t\t<orari>";
	$node .= "\n\t\t\t<lun>$tag{lun}</lun>";
	$node .= "\n\t\t\t<mar>$tag{mar}</mar>";
	$node .= "\n\t\t\t<mer>$tag{mer}</mer>";
	$node .= "\n\t\t\t<gio>$tag{gio}</gio>";
	$node .= "\n\t\t\t<ven>$tag{ven}</ven>";
	$node .= "\n\t\t\t<sab>$tag{sab}</sab>";
	$node .= "\n\t\t\t<dom>$tag{dom}</dom>";
	$node .= "\n\t\t</orari>";
    }
    else{$node.= "\n\t\t<$_>$tag{$_}</$_>" foreach keys %tag;}
    $node.= "\n\t</$element>\n";
    return $node;
};

sub new { bless {}, shift }

sub init {
    my ($self, $session, $cgi) = @_;
    if ( $session->param("~logged-in") ) {
	$session->expire(720);
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
    my $ret = $root->exists("//profilo[username='$user' and password='$passwd']");
    if($ret){
	return $user;
    }
    
    return undef;
}

sub add_resource {
    my $self = shift;
    my %stash = @_;
    my ($suffix, $element, $action, $from) = split (/:/, $stash{'namespace'});
    my $path = $self->$_get_path($suffix);
    my $parser = XML::LibXML->new();
    my $xml = $parser->parse_file($path);
    my $root = $xml->getDocumentElement();
#    $xml->documentElement->setNamespace("www.$suffix.it","n");
    my $id = $stash{'id'} || $self->$_get_last_id($xml, $element);
    delete $stash{'namespace'};
    delete $stash{'formfor'};
    delete $stash{'id'};
    my $ret = $self->$_build_node($action, $element, $id, %stash);
    my $token = $xml->getElementsByTagName($suffix)->[0];
    my $chunk = $parser->parse_balanced_chunk($ret);
    if($action eq 'add'){
	$token->appendChild($chunk); # fare un $token->lastChild ed estrarre l'id, inserire ++id nel nuovo nodo
    }
    elsif($action eq 'edit'){
	if($root->exists($element."[\@id=$id]")){
	    $token = $root->findnodes($element."[\@id='$id']")->get_node(1);
	    $token->replaceChild($chunk, $token) || die $!;
	}
	else { die $!; }	# condizione eliminabile
    }
    elsif($action eq 'delete'){
	$token = $root->findnodes($element."[\@id='$id']")->get_node(1);
	$token->unbindNode();
    }
    else { die $!; }		# lanciare errore
    open(OUT, ">$path") || die "error $!";
    print OUT $xml->toString || die $!; 
    close OUT;
    print CGI::header(-location => "admin.cgi?screen=$from");
}

sub dispatch {
    my $self = shift;
    my $route = shift;
    my %params = @_;
    my $template = HTML::Template->new(filename => $route.".tmpl", utf8 => 1);
    foreach(keys %params){
	$template->param($_ => $params{$_});
    }	
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
    my @loop_courses = map {{C_NAME => $_->findvalue("nome"), MONTHLY => $_->findvalue("mensile"), C_ID => $_->getAttribute("id"),
			     TRIMESTRAL => $_->findvalue("trimestrale"), SEMESTRAL => $_->findvalue("semestrale"),
			     ANNUAL => $_->findvalue("annuale"), C_LUN => $_->findvalue("orari/lun"), 
			     C_MAR => $_->findvalue("orari/mar"), C_MER => $_->findvalue("orari/mer"), 
			     C_GIO => $_->findvalue("orari/gio"), C_VEN => $_->findvalue("orari/ven"),
			     C_SAB => $_->findvalue("orari/sab"), C_DOM => $_->findvalue("orari/dom")}} @courses;
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

sub get_cdata {
    my ($self, $id) = @_;
    my $xml = $self->load_xml('../data/corsi.xml');
    my %c_data = ();
    if($xml->getDocumentElement->exists("//corso[\@id=$id]")){
	$c_data{c_name} = $xml->findvalue("//corso[\@id='$id']/nome");
	$c_data{c_monthly} = $xml->findvalue("//corso[\@id='$id']/mensile");
	$c_data{c_trimestral} = $xml->findvalue("//corso[\@id='$id']/trimestrale");
	$c_data{c_semestral} = $xml->findvalue("//corso[\@id='$id']/semestrale");
	$c_data{c_annual} = $xml->findvalue("//corso[\@id='$id']/annuale");
	$c_data{c_lun} = $xml->findvalue("//corso[\@id='$id']/orari/lun");
	$c_data{c_mar} = $xml->findvalue("//corso[\@id='$id']/orari/mar");
	$c_data{c_mer} = $xml->findvalue("//corso[\@id='$id']/orari/mer");
	$c_data{c_gio} = $xml->findvalue("//corso[\@id='$id']/orari/gio");
	$c_data{c_ven} = $xml->findvalue("//corso[\@id='$id']/orari/ven");
	$c_data{c_sab} = $xml->findvalue("//corso[\@id='$id']/orari/sab");
	$c_data{c_dom} = $xml->findvalue("//corso[\@id='$id']/orari/dom");
    }
    else {
	$c_data{not_found} = 1;
    }
    return %c_data;
}

1;
