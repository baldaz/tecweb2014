<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="news">
	<xs:complexType>
		<xs:sequence>
			<xs:element name="new">
				<xs:complexType>
					<xs:sequence>
						<xs:element name="titolo" type="xs:string"/>
						<xs:element name="data" type="xs:date"/>
						<xs:element name="contenuto" type="xs:string"/>
					</xs:sequence>
				</xs:complexType>
			</xs:element>
		</xs:sequence>
		<xs:attribute name="id" type="positiveInteger" use="required"/>
	</xs:complexType>
</xs:element>
</xs:schema>
