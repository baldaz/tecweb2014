#!/usr/bin/perl -w

use UTILS::Admin;

my $cgi = CGI->new();
my $session = CGI::Session->load() or die "Errore";

unless ($session->param("~logged-in")){
    print $session->header(-type => 'text/html', -location => 'login.cgi');
}

my $screen = $cgi->param('screen') || 'index';
my $id = $cgi->param('id') || '1';
my $admin = UTILS::Admin->new;

my %routes = (
    'index'            => \&index,
    'news'             => \&news,
    'add_news'         => \&add_news,
    'edit_news'        => \&edit_news,
#    'edit_prenotation' => \&edit_prenotation,
#    'edit_courses'     => \&edit_courses
    );

$routes{$screen}->();

sub index {
    my %params = ();
    $admin->dispatch('index', %params);
}

sub news {
    my @newslist = $admin->list_news;
    my %params = (
	newslist => \@newslist
	);
    $admin->dispatch('news', %params);
}

sub add_news {
    my %params = ();
    $admin->dispatch('add_news', %params);
}

sub edit_news {
    my %news_data = $admin->get_ndata($id);
    my %params = (
	n_title   => $news_data{n_title},
	n_content => $news_data{n_content},
	n_date    => $news_data{n_date},
	id        => $id
	);
    $admin->dispatch('edit_news', %params);
}
#$admin->dispatch($screen);
