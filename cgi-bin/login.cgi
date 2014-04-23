#!/usr/bin/perl -w

use CGI;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use CGI::Session ('-ip_match');
use UTILS;
use strict;

my $cgi=new CGI;

my $username=$cgi->param('username');
my $password=$cgi->param('pwd');
my $key="logdog";
my $encrypted_p=crypt($key, $password);

my $session=new CGI::Session();

my $profiles=UTILS::loadXml('../data/profili.xml');
UTILS::init($session, $cgi, $profiles);

$session->param("user", $username);

# TODO:
# - controllare se già loggato, sessione aperta
# - controllare dati di login, se prensenti su DB
# - redirect ad area personale / pagina di registrazione
# - notifica di login
