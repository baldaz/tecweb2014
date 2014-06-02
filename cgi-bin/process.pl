#!/usr/bin/perl -w

use strict;
use warnings;
use UTILS::Admin;

my $admin = UTILS::Admin->new;
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
    'add_p'      => 'prenotazioni:prenotazione:add',
    'add_n'      => 'news:new:add',
    'edit_p'     => 'prenotazioni:prenotazione:edit',
    'edit_n'     => 'news:new:edit',
    'update'     => 'update:update:edit',
    'clear_logs' => 'logs:log:delete'
    );

$input{'namespace'} = $action{$input{'formfor'}};
$admin->add_resource(%input);
