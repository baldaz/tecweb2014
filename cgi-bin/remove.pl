#!/usr/bin/perl -w

use XML::LibXML;

my $path='../data/prenotazioni.xml';

my $parser=XML::LibXML->new();
my $xml=$parser->parse_file($path);
$xml->documentElement->setNamespace("www.prenotazioni.it","p");
for my $dead ($xml->findnodes("//p:prenotante[p:nome = 'sd']")) {
    $dead->unbindNode;
}

$xml->toFile($path);
