#!/usr/bin/perl

use strict;
use warnings;
use UTILS::UserService;

my $cgi = CGI->new;
my $from = $cgi->param('email');
my $to = $ENV{USER}."\@studenti.math.unipd.it";
my $subject = "Message from $from";
my $message = $cgi->param('message');
my $utils = UTILS::UserService->new;

$utils->send_email($subject, $from, $to, $message);

print $cgi->header(-location => 'load.cgi?page=contatti');
