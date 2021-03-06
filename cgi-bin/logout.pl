#!/usr/bin/perl

use UTILS::Admin;

my $cgi = CGI->new;
my $page = $cgi->param("page") || 'home';
$page = "load.cgi?page=".$page unless $page eq 'login.cgi';
my $admin = UTILS::Admin->new;
my $session = CGI::Session->load($cgi) || die $!;
if($session->param("~logged-in")){
    $session->delete();
    $session->close();
    $session->flush();
}
print $cgi->header(-location => $page);
