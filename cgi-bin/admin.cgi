#!/usr/bin/perl -w

use UTILS::Admin;
use CGI qw /:standard/;
use feature qw /switch/;
use HTML::Template;

$ENV{HTML_TEMPLATE_ROOT} = "../public_html/templates/admin";
my $cgi = CGI->new();
my $session = CGI::Session->load() or die "Errore";

unless ($session->param("~logged-in")){
    print header(-type => 'text/html', -location => 'login.cgi');
}

my $screen = $cgi->param('screen') || 'index';
my $admin = UTILS::Admin->new;

$admin->dispatch($screen);
