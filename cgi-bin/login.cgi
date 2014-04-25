#!/usr/bin/perl -w

use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use CGI::Session ('-ip_match');
use UTILS;
use strict;

my $cgi=CGI->new();

my $session=CGI::Session->new($cgi);

my $profiles=UTILS::loadXml('../data/profili.xml');
UTILS::init($session, $cgi, $profiles);

my $profile = $session->param("~profile");

if($session->param("~logged-in")){
    print $session->header(-location => "admin.cgi");
}
else{
    form();
}

sub form{
    print header(), start_html(-Title => "Login");
    print start_form();
    print h5("Login");
    print pre(p("Username:  ", textfield("username")),
	      p("Password:  ", password_field("passwd")));
    print submit("sign");

    print end_form(), end_html();
}
