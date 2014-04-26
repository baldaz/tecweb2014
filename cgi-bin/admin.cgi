#!/usr/bin/perl -w

use strict;
use warnings;
use CGI qw(:standard);
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use CGI::Session ('-ip_match');
use UTILS;

my $cgi=CGI->new();
my $session=CGI::Session->load() or die "ciao";
#my $prof=UTILS::loadXml("../data/profili.xml");
#UTILS::init($session, $cgi, $prof);

unless ($session->param("~logged-in")){
    print header(-type => 'text/html', -location => 'login.cgi');
}

my %states;
my $current_screen;

%states = (
    'Default' =>  \&front_page,
    'Add'     =>  \&add,
    'Update'  =>  \&update_reservation,
    'Cancel'  =>  \&front_page,
    );

$current_screen = param(".state") || "Default";
die "No HTML per $current_screen" unless $states{$current_screen};

standard_header();
    
while(my($screen_name, $function) = each %states){
    $function->($screen_name eq $current_screen);
}

standard_footer();
exit;


sub standard_header{
    print header(), start_html(-Title => "Admin", -BGCOLOR=>"White");
    print start_form(); # start_multipart_form() if file upload
}

sub standard_footer { print end_form(), end_html() }

sub admin_menu {
    print p(defaults("Home"),
	    to_page("Add"),
	    to_page("Update"),
	    to_page("Cancel"));
}

sub front_page {
    my $active = shift;
    return unless $active;
    
    print "<H1>Hi!</H1>\n";
    print "Welcome to administration panel!  Please make your selection from ";
    print "the menu below.\n";
    
    admin_menu();
}

sub to_page{
    submit(-NAME => ".state", -VALUE => shift);
}

sub action_table{
}

sub add{
    my $active = shift;
    my @disc = ('Calcetto', 'Calciotto', 'Tennis', 'Beach Volley', 'Pallavolo');
    my @fields = qw(1 2 3 4 5);
    my ($user, $day, $time, $discipline, $campo) =
	(param("user"), param("day"), param("time"), param("discipline"), param("campo"));

    unless ($active){
	print hidden("user") if $user;
	print hidden("day") if $day;
	print hidden("time") if $time;
	print hidden("discipline") if $discipline;
	print hidden("campo") if $campo;
	return;
    }

    print h1("Add");
    print p("From here you can add new reservation for users");
    print h3("Options");
    print p("User:", textfield("user"));
    print p("Day:", textfield("day"));
    print p("Time:", textfield("time"));
    print p("Discipline:",  popup_menu("discipline",  \@disc ),
	    "Campo:", popup_menu("campo", \@fields));

    admin_menu();
}

sub update_reservation{
}
=pod
my $cgi=CGI->new();
my $session=CGI::Session->new($cgi);
my $template=HTML::Template->new(filename=>'admin.tmpl');
my $p_xml=UTILS::loadXml('../data/profili.xml');

UTILS::init($session, $cgi, $p_xml);

my $profile = $session->param("~profile");

print $session->param("~logged-in");
if($session->param("~logged-in")){
    $template->param(user=>$profile->{username});
    $template->param(form1=>0);
 #   exit(0);

}
else{
    $template->param(form1=>1);
}

print "Content-Type: text/html\n\n", $template->output;

#$session->save_param($cgi, ["username","password"]);
#my $user=$session->param("username");

#if($user eq 'admin'){
#    $template->param(user=>$user);
#    $template->param(form1=>0);
#}
#else{
#    $template->param(form1=>1);
#}

=cut
