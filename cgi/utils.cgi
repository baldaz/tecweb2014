#!/usr/bin/perl -w

sub init($){
	
	my ($page,$title)=@_;
	print $page->header(-charset=>"UTF-8"),
		$page->start_html(	-meta=>{"content"=>"width=device-width"},
							-title=>$title,
							-dtd=>['-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd'],
							-style=>[{-src=>'../css/style.css', -media=>'only screen and (min-width: 768px)'},
									{-src=>'../css/mobile.css', -media=>'only screen and (max-width: 480px)'},
									{-src=>'../css/tablet.css', -media=>'only screen and (min-width: 481px) and (max-width: 767px)'}],
							-lang=>it
							);
}

sub footer($){

	my $page=shift;
	print $page->div({id=>'footer'},
						"\n",
						$page->p("\n",
							$page->span({lang=>en}, 'Copyright'), '© 2014 CiccipanzeSulWeb',
							"\n",
								$page->a({href=>"http://validator.w3.org/check?uri=referer"},
									"\n",
									$page->img({-src=>"http://www.w3.org/Icons/valid-xhtml10", -alt=>"Valid XHTML 1.0 Strict",
											-height=>"31", -width=>"88"}),
									"\n",
										),
								"\n",
								),
						"\n",
					),
				"\n",
			$page->end_div;
}

sub parseXML($){
	my($xml, $parser)=@_;
	my @date=$xml->getElementsByTagName('data');
	my @ore=$xml->getElementsByTagName('ora');
	
	foreach $data(@date){
		print $data->toString().' ';
	}

	foreach $ora(@ore){
		print $ora->toString().' ';
	}

	my $parser = XML::LibXML->new();
	
	my $root = XML::LibXML::XPathContext->new($xml->documentElement());

	foreach my $node ($root->findnodes(q{/*/dati/indicator[@id = 'SP.DYN.CDRT.IN']/following-sibling::*})) {
   		say $_->toString for $node->childNodes;
}
}
exit;
}

sub print_table($){

	$class="prenotato";


	print '
		<table summary="">
		<caption>Prenotazioni</caption>
		<thead>
			<tr>
				<th>ORARIO</th>
				<th>Lunedi</th>
				<th>Martedi</th>
				<th>Mercoledi</th>
				<th>Giovedi</th>
				<th>Venerdi</th>
				<th>Sabato</th>
			</tr>
			<tr>
				<th>16:00</th>
					<td class="prenotato">X</td>
			</tr>	
			<tr>
				<th>17:00</th>
			</tr>
			<tr>	
				<th>18:00</th>
			</tr>
			<tr>	
				<th>19:00</th>
			</tr>
			<tr>	
				<th>20:00</th>
			</tr>
			<tr>	
				<th>21:00</th>
			</tr>
			<tr>	
				<th>22:00</th>
			</tr>
			<tr>	
				<th>23:00</th>
			</tr>	
		</thead>
		<tfoot>
		</tfoot>
		<tbody>
		</tbody>
		</table>
		';

}


1;
