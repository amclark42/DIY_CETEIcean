<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:tei="http://www.tei-c.org/ns/1.0"
   version="1.0">
  
<!--
    An XSLT 1.0 stylesheet which creates HTML5 Custom Elements from an XML document.
    The resulting HTML uses CETEIcean for display.
    
    Ashley M. Clark
    2019-08-27
  -->
  
  <xsl:output method="html" encoding="UTF-8"/>
  
  <!--  PARAMETERS  -->
  <xsl:param name="document-title">
    <xsl:variable name="teiTitle" 
      select="tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]"/>
    <xsl:choose>
      <xsl:when test="$teiTitle">
        <xsl:value-of select="normalize-space($teiTitle)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>CETEIcean</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>
  
  
  <!--  TEMPLATES  -->
  
  <xsl:template match="/">
    <html lang="en">
      <head>
        <title><xsl:value-of select="$document-title"/></title>
        <script type="application/javascript" src="../../Downloads/CETEI.js"/>
        <link rel="stylesheet" href="test/CETEIcean.css" />
      </head>
      <body>
        <div id="TEI">
          <xsl:apply-templates/>
        </div>
        <script><xsl:text>
          var xmlDoc = document.getElementById('TEI'),
              CETEIcean = new CETEI(xmlDoc);
          console.log(xmlDoc);
        </xsl:text></script>
      </body>
    </html>
  </xsl:template>
  
  <xsl:template match="*">
    <xsl:element name="tei-{local-name(.)}">
      <xsl:apply-templates select="@* | node()"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="@* | text()">
    <xsl:copy/>
  </xsl:template>
  
  <xsl:template match="processing-instruction()"/>
  
</xsl:stylesheet>