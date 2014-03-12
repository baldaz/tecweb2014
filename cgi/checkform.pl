#!/usr/bin/perl

local ($buffer, @pairs, $pair, $name, $value, %FORM);
    # Read in text
read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    # Split information into name/value pairs
    @pairs = split(/&/, $buffer);
    
    foreach $pair (@pairs)
    {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%(..)/pack("C", hex($1))/eg;
	$FORM{$name} = $value;
    }
    $first_name = $FORM{nome};
    $last_name  = $FORM{colore};

print "Content-type:text/html\r\n\r\n";
print "<html>";
print "<head>";
print "<title>Hello - Second CGI Program</title>";
print "</head>";
print "<body>";
print "<h2>Hello $first_name $last_name - Second CGI Program</h2>";
print "</body>";
print "</html>";

1;
