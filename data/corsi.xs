<?xml version="1.0" encoding="UTF-8"?>
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="corsi">
	<xs:complexType>
		<xs:sequence>
			<xs:element name="corso" maxOccurs="unbounded">
				<xs:complexType>
					<xs:sequence>
						<xs:element name="nome" type="xs:string"/>
						<xs:element name="mensile" type="xs:string"/>
						<xs:element name="trimestrale" type="xs:string"/>
						<xs:element name="semestrale" type="xs:string"/>
						<xs:element name="annuale" type="xs:string"/>
						<xs:element name="orari">
							<xs:complexType>
								<xs:sequence>
									<xs:element name="lun" type="xs:string" nillable="true"/>
									<xs:element name="mar" type="xs:string" nillable="true"/>
									<xs:element name="mer" type="xs:string" nillable="true"/>
									<xs:element name="gio" type="xs:string" nillable="true"/>
									<xs:element name="ven" type="xs:string" nillable="true"/>
									<xs:element name="sab" type="xs:string" nillable="true"/>
									<xs:element name="dom" type="xs:string" nillable="true"/>
								</xs:sequence>
							</xs:complexType>
						</xs:element>
					</xs:sequence>
					<xs:attribute name="id" type="xs:positiveInteger" use="required"/>
					</xs:complexType>
			</xs:element>
		</xs:sequence>
	</xs:complexType>
</xs:element>
</xs:schema>

