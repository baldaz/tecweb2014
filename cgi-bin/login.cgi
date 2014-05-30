#!/usr/bin/perl -w

use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use CGI::Session ('-ip_match');
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
else{
#    $admin->dispatch('login');
    form();
}

sub form{
    print header(), start_html(-Title => "Login");
    print start_form(-action => "");
    print h5("Login");
    print pre(p("Username:  ", textfield("username")),
	      p("Password:  ", password_field("passwd")));
    print submit("sign");

    print end_form(), end_html();
}
