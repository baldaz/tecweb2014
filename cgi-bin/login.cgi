#!/usr/bin/perl -w

use UTILS::Admin;

my $cgi = CGI->new();
my $session = CGI::Session->new(undef, $cgi, {Directory => '/tmp'});
my $admin = UTILS::Admin->new;
my $cookie = $cgi->cookie(CGISESSID => $session->id);
$admin->init($session, $cgi);

my $profile = $session->param("~profile");

if($session->param("~logged-in")){
    print $session->header(-location => "admin.cgi", cookie => $cookie);
}
else{ $admin->dispatch('login'); }
