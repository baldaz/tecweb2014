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
my $session = CGI::Session->new(undef, $cgi, {Directory => '/tmp'});

if (my $profile = $admin->load_profile($user, $passwd)){
#    $session = CGI::Session->new();
    $session->param("~profile", $user);
    $session->param("~logged-in", 1);
    $session->clear(["~login-trials"]);
    $session->expire(720);
    my $cookie = $cgi->cookie(CGISESSID => $session->id);
    print $session->header(-location => $page, -cookie => $cookie);
}
else {
    my $trials = $session->param("~login-trials") || 0;
    $session->param("~login-trials", ++$trials);
    my $cookie = $cgi->cookie(CGISESSID => $session->id);
    print $cgi->redirect(-location => $page, -cookie => $cookie);
}
