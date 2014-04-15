#!/usr/bin/perl -w

use strict;
use XML::LibXML;
use CGI qw (fatalsToBrowser);

###############################################################
#                                                             #
# SCRIPT DI AMMINISTRAZIONE PER INSERIMENTO CORSI FITNESS     #
# impostare i parametri oggetto CGI, titolo, data e contenuto #
#                                                             #
###############################################################

my $file='../data/courses.xml';	# inserire in prenotazioni.xml

my $parser=XML::LibXML->new();
my $xml=$parser->parse_file($file);

#$xml->documentElement->setNamespace("www.courses.it","c");

my $new=
    "
     <course>
       <nome></nome>
       <giorni></giorni>
       <orario></orario>
       <contenuto></contenuto>
     </course>
";

my $news=$xml->getElementsByTagName('courses')->[0];
my $chunk=$parser->parse_balanced_chunk($new);
$news->appendChild($chunk);

open(OUT, ">$file");
print OUT $xml->toString;
close OUT;
