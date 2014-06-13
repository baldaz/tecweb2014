#!/usr/bin/perl -w

use strict;
use warnings;
use UTILS::Admin;

my $admin = UTILS::Admin->new;
my $cgi = CGI->new();
my $page = $cgi->param("page") || 'home';
$page = "load.cgi?page=".$page; 
my $user = $cgi->param("username") or return;
my $passwd = $cgi->param("passwd") or return;
my $session;

if (my $profile = $admin->load_profile($user, $passwd)){
    $session = CGI::Session->new();
    $session->param("~profile", $user);
    $session->param("~logged-in", 1);
    $session->clear(["~login-trials"]);
    $session->expire(360);
    print $session->header(-location => $page);
}
else { print $cgi->header(-location => $page);}
