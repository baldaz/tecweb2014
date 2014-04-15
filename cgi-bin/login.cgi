#!/usr/bin/perl -w

use CGI;
use CGI::Carp qw(fatalsToBrowser);
use CGI::Session ('-ip_match');
use XML::LibXML;
use strict;

my $cgi=new CGI;

my $username=$cgi->param('username');
my $password=$cgi->param('password');
my $key="logdog";
my $encrypted_p=crypt($key, $password);

my $session=new CGI::Session();
$session->param("user", $username);

# TODO:
# - controllare se già loggato, sessione aperta
# - controllare dati di login, se prensenti su DB
# - redirect ad area personale / pagina di registrazione
# - notifica di login
