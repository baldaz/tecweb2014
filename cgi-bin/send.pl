#!/usr/bin/perl

use strict;
use warnings;
use UTILS;

my $cgi = CGI->new;
my $from = $cgi->param('email');
my $to = $ENV{USER}."\@studenti.math.unipd.it";
my $subject = "Message from $from";
my $message = $cgi->param('message');
my $utils = UTILS->new;

$utils->send_email($subject, $from, $to, $message);

print $cgi->header(-location => 'load.cgi?page=contatti');
