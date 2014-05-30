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
my $template;

$admin->dispatch($screen);
=pod
given($screen) {
    when(/front_page/) {
	# template per home admin
	$template = HTML::Template(
    }
    when(/edit_p/) {
	# template per modifica prenotazione
    }
    when(/edit_n/) {
	# template per modifica news
    }
    when(/update/) {
	# template per modifica tabelle corsi
    }
    default {
	print $cgi->redirect('admin.cgi?screen=front_page');
    }
}
=cut
=pod
$ENV{HTML_TEMPLATE_ROOT} = "../public_html/templates";
my $admin = UTILS::Admin->new;
my $cgi = CGI->new();
my $session = CGI::Session->load() or die "Errore";

unless ($session->param("~logged-in")){
    print header(-type => 'text/html', -location => 'login.cgi');
}

my %states;
my $current_screen;

%states = (
    'Default' =>  \&front_page,
    'Add'     =>  \&add,
    'Update'  =>  \&update_reservation,
    'view'    =>  \&view,
    'Cancel'  =>  \&front_page,
    );

$current_screen = param(".state") || "Default";
die "No HTML per $current_screen" unless $states{$current_screen};

$admin->admin_header();
admin_menu();    
while(my($screen_name, $function) = each %states){
    $function->($screen_name eq $current_screen);
}

$admin->admin_footer();
exit;

sub admin_menu {
    print p(defaults("Home"),
	    to_page("Add"),
	    to_page("Update"),
	    to_page("Cancel"));
}

sub front_page {
    my $active = shift;
    return unless $active;
}

sub to_page {
    submit(-NAME => ".state", -VALUE => shift);
}

sub action_table {
}

sub add {
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
    print p(to_page("view"));
}

sub update_reservation{
    my $active = shift;

    my @IDS = qw/0 1 2 3 4 5 6 7 8 9 10/;
    my @fields = qw/ID user/;
    
    my ($uid, $usr) = (param("user"), param("ID"));

    unless ($active){
	print map { hidden($_) } @fields;
	return;
    }
 
    print h1("Delete / Update");
    print p("Form here you can delete or update reservation for users");
    print h3("Data");
    print pre(p("User id:  ", popup_menu("ID", \@IDS)),
	      p("Username: ", textfield("user")));

    print p(to_page("view"));
}

sub view{
    my $active = shift;
    return unless $active;
    
    my ($uid, $usr) = (param("ID"), param("user"));
    print h1("User data");
    print p("User: $usr");
    print p("ID: $uid");
    # dati prenotazion da estrarre
}

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
