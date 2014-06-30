#!/usr/bin/perl

package UTILS::UserService;
use parent 'UTILS';
use HTML::Entities;

my $_get_path = sub {		    # da spostare su UTILS, e fare inheritance
    my $self = shift;
    return "../data/".shift.".xml";
};

sub new { bless {}, shift }

sub session_params {
    my ($self, $cgi) = @_;
    my $session = CGI::Session->load($cgi);
    my %params = ();
    if($session->param("~logged-in")){
	$params{is_logged} = 1;
	$params{profile} = $session->param("~profile");
    }
    else{
	$params{is_logged} = 0;
	if($session->param("~login-trials")){
	    $params{attempt} = 1;
	}
    }
    return %params;
}

sub get_generals {
    my ($self, $user) = @_;
    my $xml = $self->load_xml('../data/profili.xml');
    my %gens = ();
    if($xml->getDocumentElement->exists("//profilo[username='$user']")){
	$gens{name} = $xml->findvalue("//profilo[username='$user']/nome");
	$gens{surname} = $xml->findvalue("//profilo[username='$user']/cognome");
	$gens{tel} = $xml->findvalue("//profilo[username='$user']/telefono");
    }
    else {
	$gens{not_found} = 1;
    }
    return %gens;
}

sub get_prenotations {
    my ($self, $user) = @_;
    my $xml = $self->load_xml('../data/prenotazioni.xml');
    my @loop_prens = ();
    if($xml->getDocumentElement->exists("//p:prenotante[p:email='$user']")){
	my @prenotations = $xml->findnodes("//p:prenotante[p:email='$user']");
	@loop_prens = map {{discipline => $prenotations[0]->findnodes("//p:prenotante[p:email='$user']/p:disciplina")->get_node($_)->textContent, 
			    data       => $prenotations[0]->findnodes("//p:prenotante[p:email='$user']/p:data")->get_node($_)->textContent,
			    ora        => $prenotations[0]->findnodes("//p:prenotante[p:email='$user']/p:ora")->get_node($_)->textContent, 
			    campo      => $prenotations[0]->findnodes("//p:prenotante[p:email='$user']/p:campo")->get_node($_)->textContent
	    }} 1..@prenotations;
    }
    else {
	@loop_prens = ();
	return @loop_prens;
    }
    return @loop_prens;
}

sub filter_input {
    my ($self, $input) = @_;
    return HTML::Entities::encode($input);
}

# controllo numero telefonico

sub validate_tel {
    my ($self, $number) = @_;
    if($number =~ /^(\d)+$/){
	return 1;
    }
    else{ return 0; }
}

1;
