#!/usr/bin/perl

use UTILS::Admin;

my $admin = UTILS::Admin->new;
=pod
my $cgi = CGI->new();
my $session = CGI::Session->load($cgi) or die "Errore";

unless ($session->param("~logged-in")){
    print $session->header(-type => 'text/html', -location => 'login.cgi');
}
=cut
my %input = ();
read(STDIN, my $buffer, $ENV{'CONTENT_LENGTH'});
if(!length($buffer)){ 
    my %err = (
	err_code => '404',
	err_desc => 'Nessun argomento inserito',
	);
    $admin->dispatch('error', %err);
}
else{
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
	);
    
    if(!exists $action{$input{'formfor'}}){
	my %err = (
	    err_code => '400',
	    err_desc => 'Operazione non consentita'
	    );
	$admin->dispatch('error', %err);
    }
    $input{'namespace'} = $action{$input{'formfor'}};
    $admin->_resource(%input);
}
