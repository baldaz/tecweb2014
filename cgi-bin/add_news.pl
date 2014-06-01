#!/usr/bin/perl -w

use strict;
use XML::LibXML;
use CGI qw (fatalsToBrowser);

my %input;
read(STDIN, my $buffer, $ENV{'CONTENT_LENGTH'});
my @pairs = split(/&/, $buffer);
foreach my $pair (@pairs){
    my ($name, $value) = split(/=/, $pair);
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg; 
    $value =~ s/@/"\/@"/eg;
    $name =~ tr/+/ /; 
    $name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C",hex($1))/eg; 
    $input{$name} = $value;
}

my %dispatch = (
    'news'        => \&news,
    'prenotation' => \&prenotation
    );

$dispatch{$input{'formfor'}}->();

sub news {
    my $path = '../data/news.xml';
    my $elem ="\n<new>
                   <titolo></titolo>
                   <data></data>
                   <contenuto></contenuto>
                  </new>";
    my %stash = (
	$path => $elem
	);
}

sub prenotation {
    print "Content-type: text/html\n\n";
    print "prenotation";
}
=pod
my $file='../data/news.xml';	# inserire in prenotazioni.xml

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
=cut
