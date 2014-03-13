<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" 
xmlns="www.prenotazioni.it" 
targetNamespace="www.prenotazioni.it" 
elementFormDefault="unqualified">
<xs:element name="dati">
	<xs:element name="prenotazioni">
		<xs:complexType>
			<xs:sequence>
				<xs:element name="prenotante">
					<xs:complexType>
						<xs:sequence>
							<xs:element name="nome" type="xs:string" use="required" />
							<xs:element name="cognome" type="xs:string" use="required" />
							<xs:element name="telefono" type="xs:positiveInteger" use="required"/>
							<xs:element name="email" use="required"> 
		  						<xs:restriction base="xsd:string"> 
		   						<xs:pattern value="[^@]+@[^\.]+\..+"/> 
		   					</xs:restriction>  
							</xs:element>
							<xs:element name="disciplina" use="required" >
								<xs:restriction base="xsd:string">
									<xs:enumeration value="Calcetto"/>
									<xs:enumeration value="Calciotto"/>
									<xs:enumeration value="Tennis"/>
									<xs:enumeration value="Pallavolo"/>
									<xs:enumeration value="Beach Volley"/>
								</xs:restriction>
							</xs:element>
							<xs:element name="data" type="xs:date" use="required"/>
							<xs:element name="ora" type="xs:positiveInteger" use="required"/>
						</xs:sequence>
					</xs:complexType>
				</xs:element>
			</xs:sequence>
		</xs:complexType>
	</xs:element>
</xs:element>
</xs:schema>
