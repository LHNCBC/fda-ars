<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet 
    xmlns:v3="urn:hl7-org:v3"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0"
    >

  <!-- Note: namespace support is broken -->
  <!-- xsl:output version="1.0" indent="no" method="text" omit-xml-declaration="yes" / -->
  <xsl:output method="html"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <html><body>
      <xsl:apply-templates/>
    </body></html>
  </xsl:template>

  <xsl:template match="/v3:document/v3:title">
    <h1 align="center"> 
    <xsl:apply-templates/> </h1>
  </xsl:template>

  <xsl:template match="v3:paragraph">
    <p> <xsl:apply-templates/> </p>
  </xsl:template>
  
  <xsl:template match="v3:text">
    <quote><xsl:apply-templates/></quote>
  </xsl:template>

  <xsl:template match="v3:section/v3:component/v3:section/v3:title">
    <h3><xsl:apply-templates/></h3>
  </xsl:template>

  <xsl:template match="v3:caption">
  </xsl:template>

  <xsl:template match="v3:tr/v3:td">
    <quote><xsl:apply-templates/></quote> <br/>
  </xsl:template>

  <xsl:template match="v3:tr/v3:td/v3:content[@styleCode='italics']">
    <!-- suppress group table headers -->
  </xsl:template>

  

  <!-- '34066-1' : 'BOXED WARNINGS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34066-1']]" priority="1">
    <div id="boxed_warnings">
	<h2>
	  <em>BOXED WARNING: </em> <xsl:value-of select="v3:title"/>
	</h2>
	<xsl:apply-templates/>
    </div> <!-- BOXED WARNINGS -->
  </xsl:template>

  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34066-1']]/text">
    <quote><xsl:apply-templates/></quote>
  </xsl:template>

  <!-- '34084-4' : 'ADVERSE REACTIONS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34084-4']]" priority="1">
    <div id="adverse_reactions"> 
      <xsl:apply-templates/>
    </div> <!-- ADVERSE REACTIONS -->
  </xsl:template>

  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34084-4']]/title">
    <h2><xsl:apply-templates/></h2>
  </xsl:template>


  <!-- '43684-0' : 'USE IN SPECIFIC POPULATIONS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43684-0']]" priority="1">
    <div id="use_in_specific_populations"> <xsl:apply-templates/>
  </div> <!-- USE IN SPECIFIC POPULATIONS -->
  </xsl:template>


  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43684-0']]/title">
    <h2> <xsl:apply-templates/> </h2> 
  </xsl:template>

  
  <!-- '43685-7' : 'WARNINGS AND PRECAUTIONS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43685-7']]" priority="1">
    <div id="warnings_and_precautions"> <xsl:apply-templates/>
  </div> <!-- WARNINGS AND PRECAUTIONS -->
  </xsl:template>

  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43685-7']]/title">
    <h2><xsl:apply-templates/></h2>
  </xsl:template>

  <!-- '34071-1' : 'WARNINGS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34071-1']]" priority="1">
    <div id="warnings"> <xsl:apply-templates/>
  </div>  <!-- WARNINGS -->
  </xsl:template>
  
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34071-1']]/title">
    <h2><xsl:apply-templates/></h2>
  </xsl:template>

  <!-- '42232-9' : 'PRECAUTIONS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='42232-9']]" priority="1">
    <div id="precautions"> <xsl:apply-templates/>
  </div><!-- PRECAUTIONS -->
  </xsl:template>


  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='42232-9']]/title" priority="1">
    <h2><xsl:apply-templates/></h2>
  </xsl:template>

    

  <!-- ignored sections -->

  <xsl:template match="author"/>

  <!-- '48780-1' "SPL PRODUCT DATA ELEMENTS SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='48780-1']]"/>

  <!-- "43678-2" "DOSAGE FORMS &amp; STRENGTHS SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43678-2']]"/>

  <!-- "51945-4" "PACKAGE LABEL.PRINCIPAL DISPLAY PANEL" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='51945-4']]"/>

  <!-- "34070-3"  "CONTRAINDICATIONS SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34070-3']]"/>

  <!-- '43683-2' "RECENT MAJOR CHANGES SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43683-2']]"/>

  <!-- '34067-9' "INDICATIONS &amp; USAGE SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34067-9']]"/>
  
  <!-- "42229-5" "SPL UNCLASSIFIED SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='42229-5']]"  priority="0"/>

  <!-- '34068-7' "DOSAGE &amp; ADMINISTRATION SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34068-7']]" priority="1"/>

  <!-- "34088-5" "OVERDOSAGE SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34088-5']]"/>

  <!-- "34089-3" "DESCRIPTION SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34089-3']]"/>

  <!--   "34090-1" "CLINICAL PHARMACOLOGY SECTION"  -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34090-1']]"/>

  <!-- "34092-7" "CLINICAL STUDIES SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34092-7']]" priority="0.2"/>

  <!-- "34093-5" "REFERENCES SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34093-5']]"/>

  <!-- "34069-5" "HOW SUPPLIED SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34069-5']]"/>

  <!-- "34073-7" "DRUG INTERACTIONS SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34073-7']]" priority="0.7"/>  

  <!-- 34076-0" "INFORMATION FOR PATIENTS SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34076-0']]"/>

  <!-- 42230-3 PATIENT INFORMATION LEAFLET -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='42230-3']]"/>

  <!-- "43680-8" "NONCLINICAL TOXICOLOGY SECTION" -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43680-8']]"/>


</xsl:stylesheet>
