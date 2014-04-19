#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use CGI::Carp 'fatalsToBrowser';
use CGI::Session;
use HTML::Template;
use XML::LibXML;
use UTILS;

#require 'utils.pl';

my $cgi=CGI->new();
my $session=CGI::Session->new();
my $template=HTML::Template->new(filename=>'admin.tmpl');
my $parser=XML::LibXML->new();
my $p_xml=$parser->parse_file('../data/profili.xml');

UTILS::init($session, $cgi, $p_xml);

my $profile = $session->param("~profile");

if($session->param("~logged-in")){
    $template->param(user=>$profile);
    $template->param(form1=>0);
    print "Content-Type: text/html\n\n", $template->output;
    exit(0);

}
else{
    $template->param(form1=>1);
    print "Content-Type: text/html\n\n", $template->output;
}

#$session->save_param($cgi, ["username","password"]);
#my $user=$session->param("username");

#if($user eq 'admin'){
#    $template->param(user=>$user);
#    $template->param(form1=>0);
#}
#else{
#    $template->param(form1=>1);
#}

