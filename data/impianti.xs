<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="impianti">
	<xs:complexType>
		<xs:sequence>
			<xs:element name="impianto">
				<xs:complexType>
					<xs:sequence>
						<xs:element name="disciplina" type="xs:string"/>
						<xs:element name="campo" type="xs:positiveInteger"/>
					</xs:sequence>
				</xs:complexType>
			</xs:element>
		</xs:sequence>
	</xs:complexType>
</xs:element>
</xs:schema>
