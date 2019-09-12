<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:tei="http://www.tei-c.org/ns/1.0"
   version="1.0">
<!--
    An XSLT 1.0 stylesheet which creates HTML5 Custom Elements from an XML document.
    The resulting HTML uses CETEIcean for display.
    
    Ashley M. Clark
    https://gist.github.com/amclark42/0a66f46718c75c3053a06e4b4933746c
    
    Changelog:
    2019-09-12: Made sure CETEIcean registers and processes all XSL-made custom 
      elements. Recreated some of the processing that CETEIcean does on @xml:id and
      @xml:lang: the attributes get copied and their HTML equivalents (@id, @lang) 
      are also added. Set serialization such that no whitespace is added for 
      indentation purposes.
    2019-08-27: Created this stylesheet.
  -->
  
  <xsl:output method="html" encoding="UTF-8" indent="no"/>
  
  <!--  PARAMETERS  -->
  
  <!-- The path to the directory where the web assets (CSS, JS, etc.) are stored. By 
    default, this stylesheet assumes that web assets are stored in the same 
    directory as the XML file. -->
  <xsl:param name="assets-path" select="'.'"/>
  
  <!-- The title of the HTML document, which will be displayed as the name of the 
    tab or window. By default, this stylesheet will try to use the TEI <title> in 
    the <titleStmt>. -->
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
    <xsl:variable name="els">
        <xsl:text>[</xsl:text>
        <xsl:for-each select="//*">
            <xsl:text>"tei:</xsl:text>
            <xsl:value-of select="local-name(.)"/>
            <xsl:text>"</xsl:text>
            <xsl:if test="not(position() = last())">
                <xsl:text>, </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
    </xsl:variable>
    <html lang="en">
      <head>
        <title><xsl:value-of select="$document-title"/></title>
        <!-- WEB ASSETS GO HERE -->
        <script type="application/javascript" src="{$assets-path}/CETEI.js"/>
        <script type="application/javascript" src="{$assets-path}/behaviors.js" />
        <link rel="stylesheet" href="{$assets-path}/CETEIcean.css" />
        <link rel="stylesheet" href="{$assets-path}/custom.css"/>
        <!-- END WEB ASSETS -->
      </head>
      <body>
        <div id="TEI">
          <xsl:apply-templates/>
        </div>
        <script><xsl:text>
          var xmlDoc = document.getElementById('TEI'),
              CETEIcean = new CETEI(xmlDoc),
              xsltEls = new Set(</xsl:text><xsl:value-of select="$els"/><xsl:text>);
          if ( ceteiceanBehaviors !== undefined ) {
            CETEIcean.addBehaviors(ceteiceanBehaviors);
            CETEIcean.applyBehaviors();
          }
          CETEIcean.define(xsltEls);
          console.log(document.querySelector('tei-TEI') instanceof HTMLElement);
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
  
  <xsl:template match="@xml:id">
    <xsl:copy-of select="."/>
    <xsl:attribute name="id">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@xml:lang">
    <xsl:copy-of select="."/>
    <xsl:attribute name="lang">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
</xsl:stylesheet>