#!/usr/bin/perl -w

use strict;
use warnings;
use UTILS::Admin;

my $admin = UTILS::Admin->new;
my %input = ();
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
    'add_c'      => 'corsi:corso:add:courses',
    'add_n'      => 'news:new:add:news',
    'edit_c'     => 'corsi:corso:edit:courses',
    'edit_n'     => 'news:new:edit:news',
    'update'     => 'update:update:edit:update_n',
    'clear_logs' => 'logs:log:delete:clear_logs'
    );
    
$input{'namespace'} = $action{$input{'formfor'}};
$admin->add_resource(%input);
