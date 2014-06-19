#!/usr/bin/perl -w

package UTILS::UserService;
use parent 'UTILS';

my $_get_path = sub {		    # da spostare su UTILS, e fare inheritance
    my $self = shift;
    return "../data/".shift.".xml";
};

sub new { bless {}, shift }

sub is_logged {
    my $self = shift;
    my $session = CGI::Session->load();
    if($session->param("~logged-in")){
	return 1;
    }
    return 0;
}

sub get_user {
    my $self = shift;
    my $session = CGI::Session->load();
    return $session->param("~profile");
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
