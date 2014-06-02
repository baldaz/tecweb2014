#!/usr/bin/perl -w

use UTILS::Admin;
use strict;

my $cgi = CGI->new();
my $session = CGI::Session->new($cgi);
my $admin = UTILS::Admin->new;

$admin->init($session, $cgi);

my $profile = $session->param("~profile");

if($session->param("~logged-in")){
    print $session->header(-location => "admin.cgi");
}
else{ $admin->dispatch('login'); }
