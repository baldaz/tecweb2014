#!/usr/bin/perl 

use UTILS::UserService;

my $cgi = CGI->new;
my $utils = UTILS::UserService->new;

my $campo = $cgi->param('campo');
my $data = $cgi->param('data');
my $ora = $cgi->param('ora');
my $disciplina = $cgi->param('disciplina');
unless($utils->is_logged){
    print $cgi->header(-location => 'load.cgi?page=personale');
    return;
}
my $user = $utils->get_user;
my $parser = XML::LibXML->new();
my $path = '../data/prenotazioni.xml';
my $xml = $parser->parse_file($path);
my $root = $xml->getDocumentElement();
my $xpath = "//p:prenotante[p:email='$user' and p:disciplina='$disciplina' and p:data='$data' and p:ora='$ora']";
if($root->exists($xpath)){
    $token = $root->findnodes($xpath)->get_node(1);
    $token->unbindNode();
}
open(OUT, ">$path") || die "error $!";
print OUT $xml->toString || die $!; 
close OUT;
print $cgi->header(-location => 'load.cgi?page=personale');
