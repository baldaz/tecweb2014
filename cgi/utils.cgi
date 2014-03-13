#!/usr/bin/perl -w

sub init($){
	
	my ($page,$title)=@_;
	print $page->header(-charset=>"UTF-8"),
		$page->start_html(
							-title=>$title,
							-dtd=>['-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'],
							-style=>[{-src=>'../css/style.css', -media=>'only screen and (min-width: 768px)'},
									{-src=>'../css/mobile.css', -media=>'only screen and (max-width: 480px)'},
									{-src=>'../css/tablet.css', -media=>'only screen and (min-width: 481px) and (max-width: 767px)'}],
							-lang=>it
							)
}


1;
