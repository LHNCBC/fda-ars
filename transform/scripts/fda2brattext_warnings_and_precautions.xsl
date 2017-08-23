<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- render "warnings and precautions" and  suppress all other sections -->
<xsl:stylesheet 
    xmlns:v3="urn:hl7-org:v3"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0"
    >

  <xsl:output version="1.0" indent="no" method="text" omit-xml-declaration="yes" />
  <xsl:strip-space elements="*"/>

  <!-- remove any unwanted newlines and spaces -->
  <xsl:template match="*/text()[normalize-space()]">
    <xsl:value-of select="normalize-space()"/>
  </xsl:template>
  
  <xsl:template match="*/text()[not(normalize-space())]" />
  
  <!-- new line for text output -->
  <xsl:variable name="e"><xsl:text>&#xa;</xsl:text></xsl:variable>

  <!-- tab -->
  <xsl:variable name="tab"><xsl:text>&#x9;</xsl:text></xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- suppress top level title -->
  <xsl:template match="/v3:document/v3:title"/>

  <!-- suppress top level author -->
  <xsl:template match="/v3:document/v3:author"/>

  <!-- suppress top level legalAuthenticator -->
  <xsl:template match="/v3:document/v3:legalAuthenticator"/>

  <!-- emit only subtitles -->
  <xsl:template match="v3:section//v3:title">
    <xsl:text>   </xsl:text> <xsl:apply-templates/> <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="v3:excerpt">
    <xsl:text> </xsl:text> EXCERPT: <xsl:apply-templates/> <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>

  <xsl:template match="v3:paragraph">
    <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text>&#xa;&#xa;</xsl:text>
  </xsl:template>

  <!-- Rules to add padding to elements after stripping excessive whitespace -->
  <xsl:template match="v3:content">
    <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text>  </xsl:text>
  </xsl:template>

  <xsl:template match="v3:sup">
    <xsl:text>  </xsl:text> <xsl:apply-templates/> <xsl:text>  </xsl:text>
  </xsl:template>

  <xsl:template match="v3:linkHtml">
    <xsl:text>  </xsl:text> <xsl:apply-templates/> <xsl:text>  </xsl:text>
  </xsl:template>

  <xsl:template match="v3:footnote">
    <xsl:text>@footnote{</xsl:text> <xsl:apply-templates/> <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="v3:text">
    <xsl:text> </xsl:text> <xsl:apply-templates/>  <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="v3:table">
    <xsl:text>@table{</xsl:text> <xsl:apply-templates/> <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- don't insert newlines in paragraphs in tables -->
  <xsl:template match="v3:table//v3:paragraph">
    <xsl:text> </xsl:text> <xsl:value-of select="normalize-space(.)"/>  <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="v3:table//v3:footnote">
    <xsl:text>@footnote{</xsl:text> <xsl:value-of select="normalize-space(.)"/>  <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="v3:table//v3:text">
    <xsl:text> </xsl:text> <xsl:value-of select="normalize-space(.)"/>  <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="v3:caption">
    <xsl:text>@caption{</xsl:text> <xsl:value-of select="normalize-space(.)"/> <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="v3:col">
    <xsl:text>@col{</xsl:text>
    <xsl:text>width=</xsl:text>
    <xsl:value-of select="normalize-space(@width)"/>
    <xsl:text> align=</xsl:text>
    <xsl:value-of select="normalize-space(@align)"/>
    <xsl:text>} </xsl:text>
  </xsl:template>

  <xsl:template match="v3:colgroup">
    <xsl:text>@colgroup{</xsl:text> <xsl:apply-templates/> <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="v3:tbody">
    <xsl:text>@tbody{</xsl:text> <xsl:apply-templates/> <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="v3:tfoot">
    <xsl:text>@tfoot{</xsl:text> <xsl:apply-templates/> <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="v3:thead">
    <xsl:text>@thead{</xsl:text> <xsl:apply-templates/> <xsl:text>}</xsl:text>
  </xsl:template>
  
  <xsl:template match="v3:tr">
    <xsl:text>@tr{</xsl:text> <xsl:apply-templates/> <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="v3:tr[@styleCode='Lrule']" >
    <xsl:text>@tr[Lrule]{</xsl:text> <xsl:apply-templates/>  <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="v3:td">
    <xsl:text>@td{</xsl:text> <xsl:apply-templates/> <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="v3:th">
    <xsl:text>@th{</xsl:text> <xsl:apply-templates/> <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="v3:td[descendant::v3:content]">
    <xsl:text>@td[descendant::v3:content]{</xsl:text> <xsl:apply-templates/> <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="v3:list//v3:content">
    <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="v3:list">
    <xsl:text>@list{</xsl:text> <xsl:apply-templates/> <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="v3:item">
    <xsl:text>@item{</xsl:text> <xsl:apply-templates/> <xsl:text>}</xsl:text>
  </xsl:template>

    <xsl:template match="v3:br">
    <xsl:text>@br{}</xsl:text>
  </xsl:template>


  <!-- '43685-7' : 'WARNINGS AND PRECAUTIONS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43685-7']]" priority="1">
    <xsl:text> </xsl:text> <xsl:apply-templates/>  <xsl:text>  </xsl:text> 
  </xsl:template>

  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43685-7']]/title">
    <xsl:text>  </xsl:text> <xsl:apply-templates/>  <xsl:text>  </xsl:text> 
  </xsl:template>

  <!-- ignored sections -->

  <!-- '34066-1' : 'BOXED WARNINGS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34066-1']]" priority="1"/>

  <!-- '34084-4' : 'ADVERSE REACTIONS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34084-4']]" priority="1"/>

  <!-- '43684-0' : 'USE IN SPECIFIC POPULATIONS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43684-0']]" priority="1"/>
  
  <!-- '34071-1' : 'WARNINGS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34071-1']]" priority="1"/>

  <!-- '42232-9' : 'PRECAUTIONS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='42232-9']]" priority="1"/>

  <xsl:template match="author"/>

  <!-- Ignore any other top level section other than those specified previously. -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[(@code!='34066-1') and (@code!='34084-4') and (@code!='43684-0') and (@code!='43685-7') and (@code!='34071-1') and (@code!='42232-9')]]"/>

</xsl:stylesheet>
