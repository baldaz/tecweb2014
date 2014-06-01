#!/usr/bin/perl -w

use strict;
use warnings;
use CGI qw /:standard/;
use UTILS::Admin;

my %input;
read(STDIN, my $buffer, $ENV{'CONTENT_LENGTH'});
my @pairs = split(/&/, $buffer);
foreach my $pair (@pairs){
    my ($name, $value) = split(/=/, $pair);
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg; 
    $value =~ s/@/"\/@"/eg;
    $name =~ tr/+/ /; 
    $name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg; 
    $input{$name} = $value;
}

my %action = (
    'edit_p'     => \&edit_prenotation,
    'edit_n'     => \&edit_news,
    'update'     => \&update,
    'clear_logs' => \&clear_logs
    );

$action{$input{'formfor'}}->();

sub edit_prenotation {
    # prendi parametri per prenotazione
}

sub edit_news {
    # prendi parametri per news
}

sub update {
    # prendi parametri per tabelle corsi
}

sub clear_logs {
    # cancella i log
}
