#!/usr/bin/perl 

use UTILS::UserService;

my $cgi = CGI->new;
my $utils = UTILS::UserService->new;
my %sess_params = $utils->session_params($cgi);
my $campo = $cgi->param('campo');
my $data = $cgi->param('data');
my $ora = $cgi->param('ora');
my $disciplina = $cgi->param('disciplina');
unless($sess_params{is_logged}){
    print $cgi->header(-location => 'load.cgi?page=personale');
    return;
}
my $user = $sess_params{profile};
my $parser = XML::LibXML->new();
my $path = '../data/prenotazioni.xml';
my $xml = $parser->parse_file($path);
my $root = $xml->getDocumentElement();
my $xpath = "//prenotante[email='$user' and disciplina='$disciplina' and data='$data' and ora='$ora']";
if($root->exists($xpath)){
    $token = $root->findnodes($xpath)->get_node(1);
    $token->unbindNode();
}
open(OUT, ">$path");
print OUT $xml->toString; 
close OUT;
print $cgi->header(-location => 'load.cgi?page=personale');
