#!/usr/bin/perl -w

package UTILS::Admin;

use strict;
use warnings;
use XML::LibXML;
use CGI qw /:standard/;
use CGI::Carp qw /warningsToBrowser fatalsToBrowser/;
use CGI::Session qw /-ip-match/;
use HTML::Template;

$ENV{HTML_TEMPLATE_ROOT} = "../public_html/templates/admin";

sub new { bless {}, shift }

sub init {
    my ($self, $session, $cgi, $profiles_xml) = @_;
    if ( $session->param("~logged-in") ) {
	$session->expire(120);
	return 1;  # se già loggato posso uscire
    }
    
    my $user = $cgi->param("username") or return;
    my $passwd = $cgi->param("passwd") or return;
    
    if (my $profile = load_profile($user, $passwd, $profiles_xml)){
	$session->param("~profile", $profile);
	$session->param("~logged-in", 1);
	$session->clear(["~login-trials"]);
	$session->expire(120);
	return 1;
    }

    # a questo punto le credenziali sono errate

    my $trials = $session->param("~login-trials") || 0;
    return $session->param("~login-trials", ++$trials);
}

sub load_profile {
    my ($self, $user, $passwd, $profiles_xml) = @_;
    my $root = $profiles_xml->getDocumentElement;
    $profiles_xml->documentElement->setNamespace("www.profili.it", "p");
				# controllo se esiste un match (profilo esistente) 
    my $ret = $root->exists("//p:profilo[p:username='$user' and p:password='$passwd']");
    if($ret){
	my $p_mask = "x".length($passwd);
	return { username => $user, password => $p_mask };
    }
    
    return undef;
}

sub admin_header{
    print header(), start_html(-Title => "Admin", -BGCOLOR=>"White");
    print "<h1>Hi</h1>\n";
    print "Administration panel \n";
    print start_form(-action => ""); # start_multipart_form() if file upload
}

sub admin_footer { print end_form(), end_html() }

sub dispatch {
    my ($self, $screen) = @_;
    my $template = HTML::Template->new(filename => $screen.".tmpl");
    print "Content-Type: text/html\n\n", $template->output;
}
# funzione di modifica generica
=pod
sub update{
    my($filter, $old_data, $new_data)=@_;
    my $xml;
    given($filter){
	when(/news/){
	    $xml=loadXml('..data/prenotazioni.xml');
	}
	when(/corso/){
	    $xml=loadXml('..data/corsi.xml');
	}
	when(/impianto/){
	    $xml=loadXml('..data/impianti.xml');
	}
	when(/contatto/){
	}
	when(/prenotazione/){
	    $xml=loadXml('..data/prenotazioni.xml');
	}
	default{
	}
    }
}
=cut

1;
