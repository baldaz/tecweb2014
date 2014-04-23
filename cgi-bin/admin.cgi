#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use CGI::Session ('-ip_match');
use HTML::Template;
use UTILS;

my $cgi=CGI->new();
my $session=CGI::Session->new($cgi);
my $template=HTML::Template->new(filename=>'admin.tmpl');
my $p_xml=UTILS::loadXml('../data/profili.xml');

UTILS::init($session, $cgi, $p_xml);

my $profile = $session->param("~profile");

print $session->param("~logged-in");
if($session->param("~logged-in")){
    $template->param(user=>$profile->{username});
    $template->param(form1=>0);
 #   exit(0);

}
else{
    $template->param(form1=>1);
}

print "Content-Type: text/html\n\n", $template->output;

#$session->save_param($cgi, ["username","password"]);
#my $user=$session->param("username");

#if($user eq 'admin'){
#    $template->param(user=>$user);
#    $template->param(form1=>0);
#}
#else{
#    $template->param(form1=>1);
#}

