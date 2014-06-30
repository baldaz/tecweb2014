#!/usr/bin/perl -w

use UTILS::UserService;

my $cgi = CGI->new();
my $utils = UTILS::UserService->new;
my $table = "<h3>Tabelle prenotazione:</h3>";
my $disciplina = $cgi->param('disciplina') || 'Calcetto';
my $today = $utils->_today;
my $data = $cgi->param('data') || $today->ymd("-");
my $nr_campi = $utils->getFields($disciplina);
$nr_campi = 2 if not defined $nr_campi;
for(1..$nr_campi){
    $table.= $utils->getWeek($disciplina, $_, $data);
}
print $cgi->header('text/html;charset=UTF-8');
print $table;
