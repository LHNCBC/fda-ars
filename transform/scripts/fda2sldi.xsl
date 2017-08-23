<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet
    xmlns:v3="urn:hl7-org:v3"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    version="2.0"
    >
  <xsl:output version="1.0" indent="no" method="text" omit-xml-declaration="yes" />
  <xsl:strip-space elements="*"/>
  <xsl:preserve-space elements="v3:table"/>

  <!-- field delimiter for id|text output -->
  <xsl:variable name="delim">|</xsl:variable>

  <!-- field delimiter for sections output -->
  <xsl:variable name="poundsign">#</xsl:variable>

  <!-- new line for text output -->
  <xsl:variable name="newline"><xsl:text>&#xa;</xsl:text></xsl:variable>

  <!-- tab -->
  <xsl:variable name="tab"><xsl:text>&#x9;</xsl:text></xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
  
  <!-- discard the drug label title and all section and sub-section titles-->
  <xsl:template match="v3:title"/>

  <!-- Rules to add padding to elements after stripping excessive whitespace -->
  <xsl:template match="v3:caption">
    <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="v3:footnote">
    <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="v3:br">
    <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="v3:tr">
    <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="v3:td">
    <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="v3:th">
    <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text> </xsl:text>
  </xsl:template>
  
  <!-- The v3:section/v3:excerpt, v3:table, and v3:paragraph templates take
       the title and subtitle parameters and prepend them to the
       accumulated text data from the child nodes with the title,
       subtitle, and child textdata separated by pipe separator
       characters, for example:

BOXED WARNING: WARNING: PROGRESSIVE MULTIFOCAL LEUKOENCEPHALOPATHY (PML)#|JC virus infection resulting ...
BOXED WARNING: WARNING: PROGRESSIVE MULTIFOCAL LEUKOENCEPHALOPATHY (PML)#|WARNING: PROGRESSIVE MULTIFOCAL ...
5 WARNINGS AND PRECAUTIONS#5^1 Peripheral Neuropathy|ADCETRIS treatment causes a peripheral neuropathy that is ...
5 WARNINGS AND PRECAUTIONS#5^2 Infusion Reactions|Infusion-related reactions, including anaphylaxis, have ...
  -->

  <!-- The text, paragraph, and excerpt elements subsume textdata of
       child elements: paragraph, or excerpt elements, except when inside
       of a table.  Tables elements are treated as top level elements of
       a subseection and subsume any text, paragraph, and excerpt
       elements.
  -->
  <xsl:template match="v3:section/v3:excerpt">
    <xsl:param name="title" tunnel="yes"/>
    <xsl:param name="subtitle" tunnel="yes"/>

    <xsl:variable name="textdata"> <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text> </xsl:text> </xsl:variable>
    <xsl:variable name="cleantitle"> <xsl:value-of select="translate(translate($title,'.','^'),$tab,' ')"/> </xsl:variable>
    <xsl:variable name="cleansubtitle"> <xsl:value-of select="translate(translate($subtitle,'.','^'),$tab,' ')"/> </xsl:variable>
    <xsl:value-of select="concat($cleantitle,$poundsign,$cleansubtitle,$poundsign,'excerpt',$delim,normalize-space($textdata),$newline)"/>
  </xsl:template>
  
  <!-- treat any text or paragraph in a excerpt as content for the excerpt. -->
  <xsl:template match="v3:section/v3:excerpt//v3:paragraph" priority="1">
    <xsl:text> </xsl:text> <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="v3:section/v3:excerpt//v3:text">
    <xsl:text> </xsl:text> <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="v3:section/v3:paragraph">
    <xsl:param name="title" tunnel="yes"/>
    <xsl:param name="subtitle" tunnel="yes"/>

    <!-- everything but tables -->
    <xsl:for-each select="*[not(self::v3:table)]">
      <xsl:variable name="textdata"> <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text> </xsl:text> </xsl:variable>
      <xsl:variable name="cleantitle"> <xsl:value-of select="translate(translate($title,'.','^'),$tab,' ')"/> </xsl:variable>
      <xsl:variable name="cleansubtitle"> <xsl:value-of select="translate(translate($subtitle,'.','^'),$tab,' ')"/> </xsl:variable>
      <xsl:value-of select="concat($cleantitle,$poundsign,$cleansubtitle,$poundsign,'paragraph',$delim,normalize-space($textdata),$newline)"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="v3:section/v3:text">
    <xsl:param name="title" tunnel="yes"/>
    <xsl:param name="subtitle" tunnel="yes"/>
    <xsl:variable name="cleantitle"> <xsl:value-of select="translate(translate($title,'.','^'),$tab,' ')"/> </xsl:variable>
    <xsl:variable name="cleansubtitle"> <xsl:value-of select="translate(translate($subtitle,'.','^'),$tab,' ')"/> </xsl:variable>

    <!-- everything but tables -->
    <xsl:for-each select="*[not(self::v3:table)]">
      <xsl:variable name="textdata"> <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text> </xsl:text> </xsl:variable>
      <xsl:value-of select="concat($cleantitle,$poundsign,$cleansubtitle,$poundsign,'text',$delim,normalize-space($textdata),$newline)"/>
    </xsl:for-each>

    <xsl:for-each select="v3:table">
      <xsl:variable name="textdata"> <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text> </xsl:text> </xsl:variable>
      <xsl:value-of select="concat($cleantitle,$poundsign,$cleansubtitle,$poundsign,'table',$delim,normalize-space($textdata),$newline)"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="v3:text/v3:paragraph">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="v3:table">
    <xsl:param name="title" tunnel="yes"/>
    <xsl:param name="subtitle" tunnel="yes"/>

    <xsl:variable name="textdata"> <xsl:text> </xsl:text> <xsl:apply-templates/> <xsl:text> </xsl:text> </xsl:variable>
    <xsl:variable name="cleantitle"> <xsl:value-of select="translate(translate($title,'.','^'),$tab,' ')"/> </xsl:variable>
    <xsl:variable name="cleansubtitle"> <xsl:value-of select="translate(translate($subtitle,'.','^'),$tab,' ')"/> </xsl:variable>
    <xsl:value-of select="concat($cleantitle,$poundsign,$cleansubtitle,$poundsign,'table',$delim,normalize-space($textdata),$newline)"/>
  </xsl:template>

  <!-- treat any paragraph in a table as content for the table. -->
  <xsl:template match="v3:table//v3:paragraph">
    <xsl:text> </xsl:text> <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="v3:table//v3:content">
    <xsl:text> </xsl:text> <xsl:apply-templates/>
  </xsl:template>
  
  <!-- '34066-1' : 'BOXED WARNINGS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34066-1']]" priority="1">
    <xsl:variable name="title">BOXED WARNING: <xsl:value-of select="normalize-space(v3:title)"/></xsl:variable>
    <xsl:variable name="subtitle"> <xsl:value-of select="v3:component/v3:section/v3:title"/> </xsl:variable>
    <xsl:apply-templates>
      <xsl:with-param name="title" select="$title" tunnel="yes"/>
      <xsl:with-param name="subtitle" select="$subtitle" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- '34084-4' : 'ADVERSE REACTIONS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34084-4']]" priority="1">
    <xsl:variable name="title"><xsl:value-of select="normalize-space(v3:title)"/></xsl:variable>
    <xsl:apply-templates>
      <xsl:with-param name="title" select="$title" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>


  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34084-4']]/v3:component/v3:section" priority="1">
    <xsl:param name="title" tunnel="yes"/>
    <xsl:variable name="subtitle"> <xsl:value-of select="normalize-space(v3:title)"/> </xsl:variable>
    <xsl:apply-templates>
      <xsl:with-param name="title" select="$title" tunnel="yes"/>
      <xsl:with-param name="subtitle" select="$subtitle" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- '43684-0' : 'USE IN SPECIFIC POPULATIONS'(apparently does not occur in non-PLR labels) -->
  <!-- xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43684-0']]" priority="1">
    <xsl:variable name="title"><xsl:value-of select="normalize-space(v3:title)"/></xsl:variable>
    <xsl:apply-templates>
      <xsl:with-param name="title" select="$title" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template -->

  <!-- "42228-7" "PREGNANCY SECTION" of '43684-0' : 'USE IN SPECIFIC POPULATIONS', -->
  <!-- xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43684-0']]//v3:section[descendant::v3:code[@code='42228-7']]" priority="1">
    <xsl:param name="title" tunnel="yes"/>
    <xsl:variable name="subtitle"> <xsl:value-of select="normalize-space(v3:title)"/> </xsl:variable>
    <xsl:apply-templates>
      <xsl:with-param name="title" select="$title" tunnel="yes"/>
      <xsl:with-param name="subtitle" select="$subtitle" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template -->

  <!-- "34080-2" "NURSING MOTHERS SECTION" of '43684-0' : 'USE IN SPECIFIC POPULATIONS', -->
  <!-- xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43684-0']]//v3:section[descendant::v3:code[@code='34080-2']]" priority="1">
    <xsl:param name="title" tunnel="yes"/>
    <xsl:variable name="subtitle"> <xsl:value-of select="normalize-space(v3:title)"/> </xsl:variable>
    <xsl:apply-templates>
      <xsl:with-param name="title" select="$title" tunnel="yes"/>
      <xsl:with-param name="subtitle" select="$subtitle" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template -->

  <!-- "34081-0" "PEDIATRIC USE SECTION" of '43684-0' : 'USE IN SPECIFIC POPULATIONS', -->
  <!-- xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43684-0']]//v3:section[descendant::v3:code[@code='34081-0']]" priority="1">
    <xsl:param name="title" tunnel="yes"/>
    <xsl:variable name="subtitle"> <xsl:value-of select="normalize-space(v3:title)"/> </xsl:variable>
    <xsl:apply-templates>
      <xsl:with-param name="title" select="$title" tunnel="yes"/>
      <xsl:with-param name="subtitle" select="$subtitle" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template -->


  <!-- "34082-8" "GERIATRIC USE SECTION" of '43684-0' : 'USE IN SPECIFIC POPULATIONS', -->
  <!-- xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43684-0']]//v3:section[descendant::v3:code[@code='34082-8']]" priority="1">
    <xsl:param name="title" tunnel="yes"/>
    <xsl:variable name="subtitle"> <xsl:value-of select="normalize-space(v3:title)"/> </xsl:variable>
    <xsl:apply-templates>
      <xsl:with-param name="title" select="$title" tunnel="yes"/>
      <xsl:with-param name="subtitle" select="$subtitle" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template -->

  <!-- Ignore all 'USE IN SPECIFIC POPULATIONS' excerpts and
       subsections except those referenced by the templates above. -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43684-0']]/v3:excerpt" priority="1"/>
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43684-0']]/v3:component/v3:section[descendant::v3:code[(@code!='42228-7') and (@code!='34080-2') and (@code!='34081-0') and (@code!='34082-8')]]"/>

  <!-- '43685-7' : 'WARNINGS AND PRECAUTIONS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43685-7']]" priority="1">
    <xsl:param name="title" tunnel="yes"/>
    <xsl:variable name="title"><xsl:value-of select="normalize-space(v3:title)"/></xsl:variable>
    <xsl:apply-templates>
      <xsl:with-param name="title" select="$title" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='43685-7']]/v3:component/v3:section">
    <xsl:param name="title" tunnel="yes"/>
    <xsl:variable name="subtitle"> <xsl:value-of select="normalize-space(v3:title)"/> </xsl:variable>
    <xsl:apply-templates>
      <xsl:with-param name="title" select="$title" tunnel="yes"/>
      <xsl:with-param name="subtitle" select="$subtitle" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- '34071-1' : 'WARNINGS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='34071-1']]" priority="1">
    <xsl:variable name="title"><xsl:value-of select="normalize-space(v3:title)"/></xsl:variable>

    <xsl:for-each select="v3:component/v3:excerpt">
      <xsl:variable name="subtitle"> <xsl:text> </xsl:text> </xsl:variable>
      <xsl:apply-templates>
	<xsl:with-param name="title" select="$title" tunnel="yes"/>
	<xsl:with-param name="subtitle" select="$subtitle" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:for-each>

    <xsl:for-each select="v3:component/v3:section">
      <xsl:variable name="subtitle"> <xsl:value-of select="normalize-space(v3:title)"/> </xsl:variable>
      <xsl:apply-templates>
	<xsl:with-param name="title" select="$title" tunnel="yes"/>
	<xsl:with-param name="subtitle" select="$subtitle" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>

  <!-- '42232-9' : 'PRECAUTIONS', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='42232-9']]" priority="1">
    <xsl:variable name="title"><xsl:value-of select="normalize-space(v3:title)"/></xsl:variable>

    <xsl:for-each select="v3:component/v3:excerpt">
      <xsl:variable name="subtitle"> <xsl:text> </xsl:text> </xsl:variable>
      <xsl:apply-templates>
	<xsl:with-param name="title" select="$title" tunnel="yes"/>
	<xsl:with-param name="subtitle" select="$subtitle" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:for-each>
    
    <xsl:for-each select="v3:component/v3:section">
      <xsl:variable name="subtitle"> <xsl:value-of select="normalize-space(v3:title)"/> </xsl:variable>
      <xsl:apply-templates>
	<xsl:with-param name="title" select="$title" tunnel="yes"/>
	<xsl:with-param name="subtitle" select="$subtitle" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:for-each>
  </xsl:template>

  <!-- ignored sections -->

  <xsl:template match="v3:author"/>

  <!-- '42229-5' : 'SPL UNCLASSIFIED SECTION', -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[@code='42229-5']]" priority="1"/>

  <!-- Ignore any other top level section other than those specified previously. -->
  <xsl:template match="/v3:document/v3:component/v3:structuredBody/v3:component/v3:section[descendant::v3:code[(@code!='34066-1') and (@code!='34084-4') and (@code!='43684-0') and (@code!='43685-7') and (@code!='34071-1') and (@code!='42232-9')]]"/>

</xsl:stylesheet> 
