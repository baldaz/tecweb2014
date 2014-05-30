#!/usr/bin/perl -w

use strict;
use warnings;
use CGI qw /:standard/;
use UTILS::Admin;

my %action = (
    'edit_p'  => \&edit_prenotation,
    'edit_n'  => \&edit_news,
    'update' => \&update
    );

my $command = param('action') || 'null';
while(my ($action, $function) = each %action){
    $function->($action eq $command);
}

sub edit_prenotation {
    # prendi parametri per prenotazione
}

sub edit_news {
    # prendi parametri per news
}

sub update {
    # prendi parametri per tabelle corsi
}
