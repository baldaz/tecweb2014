#!/usr/bin/perl -w

use strict;
use warnings;
use CGI;
use CGI::Session qw(-ip-match);
use UTILS;

my $cgi = CGI->new();
my $page = $cgi->param("page") || 'home';
unless ($page eq 'viewB.cgi' || $page eq 'prenota.cgi'){
    $page = "load.cgi?page=".$page; 
}
my $user = $cgi->param("username") or return;
my $passwd = $cgi->param("passwd") or return;
my $profiles_xml = UTILS::loadXml('../data/profili.xml');

my $session;
if (my $profile = UTILS::load_profile($user, $passwd, $profiles_xml)){
    $session = CGI::Session->new();
    $session->param("~profile", $profile);
    $session->param("~logged-in", 1);
    $session->clear(["~login-trials"]);
    $session->expire(120);
}

print $session->header(-location => "$page");
