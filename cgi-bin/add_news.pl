#!/usr/bin/perl -w

use strict;
use XML::LibXML;
use CGI qw (fatalsToBrowser);

###############################################################
#                                                             #
# impostare i parametri oggetto CGI, titolo, data e contenuto #
#                                                             #
###############################################################

my $file='../data/news.xml';

my $parser=XML::LibXML->new();
my $xml=$parser->parse_file($file);

#$xml->documentElement->setNamespace("www.news.it","n");

my $new=
    "
     <new>
       <titolo></titolo>
       <data></data>
       <contenuto></contenuto>
     </new>
";

my $news=$xml->getElementsByTagName('news')->[0];
my $chunk=$parser->parse_balanced_chunk($new);
$news->appendChild($chunk);

open(OUT, ">$file");
print OUT $xml->toString;
close OUT;
