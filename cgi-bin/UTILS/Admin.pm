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
	$session->expire(120);
	return 1;
    }

    # a questo punto le credenziali sono errate

    my $trials = $session->param("~login-trials") || 0;
    return $session->param("~login-trials", ++$trials);
}

sub load_profile {
    my ($self, $user, $passwd) = @_;
    my $profiles_xml = $self->loadXml('../data/profili.xml');
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

sub add_resource {
    my $self = shift;
    my %stash = @_;
    my $ret;
    my ($suffix, $element, $action) = split (/:/, $stash{'namespace'});
    my $path = get_path($suffix);
    my $parser = XML::LibXML->new();
    my $xml = $parser->parse_file($path);
#    $xml->documentElement->setNamespace("www.$suffix.it","n");
    delete $stash{'namespace'};
    delete $stash{'formfor'};
    $ret = "\t<$element>";
    $ret.= "\n\t\t<$_>$stash{$_}</$_>" foreach keys %stash;
    $ret.= "\n\t</$element>\n";
    my $token = $xml->getElementsByTagName($suffix)->[0];
    my $chunk = $parser->parse_balanced_chunk($ret);
    $token->appendChild($chunk);
    open(OUT, ">$path") || die "error $!";
    print OUT $xml->toString; 
    close OUT;
}

sub get_path {			# da spostare su UTILS, e fare inheritance
    return "../data/".shift.".xml";
}

sub loadXml{
    my ($self, $path) = @_;
    my $ret = XML::LibXML->load_xml(location => $path);
}

sub dispatch {
    my ($self, $screen) = @_;
    my $template = HTML::Template->new(filename => $screen.".tmpl");
    print "Content-Type: text/html\n\n", $template->output;
}

1;
