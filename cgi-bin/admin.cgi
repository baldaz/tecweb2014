#!/usr/bin/perl -w

use UTILS::Admin;

my $cgi = CGI->new();
my $session = CGI::Session->load($cgi) or die "Errore";

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
    'del_news'         => \&del_news,
    'courses'          => \&courses,
    'add_course'       => \&add_course,
    'edit_course'      => \&edit_course,
    'del_course'       => \&del_course
    );

if(!exists $routes{$screen}){
    my %params = (
	err_code => '404',
	err_desc => 'Operazione non consentita'
	);
    $admin->dispatch('error', %params);
}
else{
    $routes{$screen}->();
}

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
    my %params = ();
    if(exists $news_data{not_found}){
	%params = (
	    err_code => '404',
	    err_desc => 'Non corrisponde alcuna risorsa all\' ID inserito'
	    );
	$admin->dispatch('error', %params);
    }
    else{
	%params = (
	    n_title   => $news_data{n_title},
	    n_content => $news_data{n_content},
	    n_date    => $news_data{n_date},
	    id        => $id
	    );
	$admin->dispatch('edit_news', %params);
    }
}

sub del_news {
    my %news_data = $admin->get_ndata($id);
    my %params = ();
    if(exists $news_data{not_found}){
	%params = (
	    err_code => '404',
	    err_desc => 'Non corrisponde alcuna risorsa all\' ID inserito'
	    );
	$admin->dispatch('error', %params);
    }
    else{
	%params = (
	    'namespace' => 'news:new:delete:news',
	    'id'        => $id
	    );
	$admin->add_resource(%params);
	#news();
	#$cgi->header(location => 'admin.cgi?screen=news');
    }
}

sub courses {
    my @courses = $admin->list_courses;
    my %params = (
	courses => \@courses
	);
    $admin->dispatch('courses', %params);
}

sub add_course {
    my %params = ();
    $admin->dispatch('add_course', %params);
}

sub edit_course {
    my %cs_data = $admin->get_cdata($id);
    my %params = ();
    if(exists $cs_data{not_found}){
	%params = (
	    err_code => '404',
	    err_desc => 'Non corrisponde alcuna risorsa all\' ID inserito'
	    );
	$admin->dispatch('error', %params);
    }
    else{
	%params = (
	    id           => $id,
	    c_name       => $cs_data{c_name},
	    c_monthly    => $cs_data{c_monthly},
	    c_trimestral => $cs_data{c_trimestral},
	    c_semestral  => $cs_data{c_semestral},
	    c_annual     => $cs_data{c_annual},
	    c_lun        => $cs_data{c_lun},
	    c_mar        => $cs_data{c_mar},
	    c_mer        => $cs_data{c_mer},
	    c_gio        => $cs_data{c_gio},
	    c_ven        => $cs_data{c_ven},
	    c_sab        => $cs_data{c_sab},
	    c_dom        => $cs_data{c_dom}
	    );
	$admin->dispatch('edit_course', %params);
    }
}

sub del_course {
    my %cs_data = $admin->get_cdata($id);
    my %params = ();
    if(exists $cs_data{not_found}){
	%params = (
	    err_code => '404',
	    err_desc => 'Non corrisponde alcuna risorsa all\' ID inserito'
	    );
	$admin->dispatch('error', %params);
    }
    else{
	%params = (
	    'namespace' => 'corsi:corso:delete:courses',
	    'id'        => $id
	    );
	$admin->add_resource(%params);
    }
}
