<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:tei="http://www.tei-c.org/ns/1.0"
   exclude-result-prefixes="tei"
   version="1.0">
<!--
    An XSLT 1.0 stylesheet which creates HTML5 Custom Elements from an XML document.
    The resulting HTML uses CETEIcean for display: https://github.com/TEIC/CETEIcean
    
    Ashley M. Clark
    https://gist.github.com/amclark42/0a66f46718c75c3053a06e4b4933746c
    
    Changelog:
    2020-08-16: Refactored the in-document Javascript to reflect updates in newer
      CETEIcean releases (v1.0.0 and above). Moved the CETEIcean Javascript code 
      into a global variable for maintainability. Added more JS and XML comments.
    2019-09-14: Added DOCTYPE and output serialization parameters for HTML5. Moved 
      CSS and JS declarations into a parameter so they are explicitly marked out for 
      customization. Further recreated bits of CETEIcean's domToHTML5() function: 
      @xmlns is moved to a data attribute, prefixes are selected based on namespace 
      URI, etc. Wrote many explanatory comments.
    2019-09-12: Made sure CETEIcean registers and processes all XSL-made custom 
      elements. Recreated some of the processing that CETEIcean does on @xml:id and
      @xml:lang: the attributes get copied and their HTML equivalents (@id, @lang) 
      are also added. Set serialization such that no whitespace is added for 
      indentation purposes.
    2019-08-27: Created this stylesheet.
  -->
  
  <!-- Several XSLT processors will produce the HTML5 DOCTYPE if <xsl:output> has 
    @method="html" and @version="5.0". -->
  <xsl:output encoding="UTF-8" indent="no" method="html" version="5.0"/>
  
  
 <!--
    PARAMETERS (customizable values)
   -->
  
  <!-- The title of the HTML document, which will be displayed as the name of the 
    tab or window. By default, this stylesheet will try to use the first TEI <title> 
    inside <titleStmt>. -->
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
  
  <!-- The path to the directory where the web assets (CSS, JS, etc.) are stored. By 
    default, this stylesheet assumes that web assets are stored in a directory named 
    "lib". -->
  <xsl:param name="assets-path" select="'./lib'"/>
  
  <!-- Web assets (CSS, Javascript) which should be included in the HTML output. -->
  <xsl:param name="web-assets">
    <script src="{$assets-path}/CETEI.js" />
    <script src="{$assets-path}/behaviors.js" />
    <link rel="stylesheet" href="{$assets-path}/basic-styles.css" />
    <link rel="stylesheet" href="{$assets-path}/custom-styles.css" />
  </xsl:param>
  
  <!-- Whether to include debugging messages, in both XSLT and Javascript. -->
  <xsl:param name="debug" select="false()"/>
  
  
 <!--
    VARIABLES
   -->
  
  <!-- Plain-text Javascript which, in a browser, will start CETEIcean. The code 
    expects to be run from an HTML document with TEI-based custom elements.
    
    I've placed this code at the top of the stylesheet for maintainability purposes. -->
  <xsl:variable name="ceteicean-startup-js">
    <xsl:text>
    /* Initialize an instance of the CETEI class. */
    var CETEIcean = new CETEI(</xsl:text><xsl:if test="$debug = true()">
          <!-- If the "debug" parameter is toggled on, turn on CETEIcean debugging 
            messages. -->
          <xsl:text>{'debug': true}</xsl:text>
        </xsl:if><xsl:text>);
        /* List out all the tag names from this XML document. */
        tagsDef = new Set(</xsl:text><xsl:call-template name="list-tags"/><xsl:text>);
    /* Add any customizations from a variable named "ceteiceanBehaviors". */
    if ( ceteiceanBehaviors !== undefined ) {
      CETEIcean.addBehaviors(ceteiceanBehaviors);
    }
    /* Register the new HTML custom elements with CETEIcean. */
    CETEIcean.define(tagsDef);</xsl:text>
  </xsl:variable>
  
  
 <!--
    TEMPLATES
   -->
  
  <!-- Build an HTML shell around the transformed TEI document. -->
  <xsl:template match="/">
    <xsl:call-template name="test-html5-output-support"/>
    <html>
      <!-- Attempt to identify and mark the primary natural language used in the 
        document. -->
      <xsl:choose>
        <xsl:when test="/*[@lang]">
          <xsl:attribute name="lang">
            <xsl:value-of select="/*/@lang"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="/*[@xml:lang]">
          <xsl:attribute name="lang">
            <xsl:value-of select="/*/@xml:lang"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
      <head>
        <title><xsl:value-of select="$document-title"/></title>
        <xsl:copy-of select="$web-assets"/>
      </head>
      <body>
        <div id="TEI">
          <xsl:apply-templates/>
        </div>
        <!-- Include Javascript code to initialize CETEIcean. -->
        <script>
          <xsl:copy-of select="$ceteicean-startup-js"/>
          <!-- Debugging: check to see if the <tei-tei> element (previously <TEI>) 
            registers as an HTML (custom) element. -->
          <xsl:if test="$debug = true()">
            <xsl:text>
    console.log(document.querySelector('tei-TEI') instanceof HTMLElement);</xsl:text>
          </xsl:if>
        </script>
      </body>
    </html>
  </xsl:template>
  
  <!-- Create an HTML custom element for every XML element. -->
  <xsl:template match="*">
    <xsl:variable name="prefix">
      <xsl:call-template name="get-prefix"/>
    </xsl:variable>
    <xsl:element name="{$prefix}-{local-name(.)}">
      <!-- Add a data attribute with the XML tag name, unaltered. (See domToHTML5() 
        in CETEI.js.) -->
      <xsl:attribute name="data-origname">
        <xsl:value-of select="local-name(.)"/>
      </xsl:attribute>
      <!-- If the current element is empty, add a data attribute marking it as such. -->
      <xsl:if test="not(*) and not(text())">
        <xsl:attribute name="data-empty"/>
      </xsl:if>
      <!-- Process this element's attributes and children. -->
      <xsl:apply-templates select="@* | node()"/>
    </xsl:element>
  </xsl:template>
  
  <!-- By default, copy attributes and text nodes into the HTML version of their 
    parent. -->
  <xsl:template match="@* | text()">
    <xsl:copy/>
  </xsl:template>
  
  <!-- By default, delete all processing instructions. -->
  <xsl:template match="processing-instruction()"/>
  
  
 <!-- Special attribute handling, based on domToHTML5() in CETEI.js. -->
  <!-- @xmlns is moved to a data attribute. -->
  <xsl:template match="@xmlns">
    <xsl:attribute name="data-xmlns">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  
  <!-- Copy the values of @xml:id and @xml:lang to @id and @lang, respectively. -->
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
  
  
 <!--
    SUBPROCESSES (named templates)
   -->
  
  <!-- Use the namespace of the current node to determine which prefix to use when 
    constructing custom HTML elements. The default prefix is "tei". -->
  <xsl:template name="get-prefix">
    <xsl:variable name="namespace" select="namespace-uri(.)"/>
    <xsl:choose>
      <xsl:when test="$namespace = 'http://www.tei-c.org/ns/1.0'">tei</xsl:when>
      <xsl:when test="$namespace = 'http://www.tei-c.org/ns/Examples'">teieg</xsl:when>
      <xsl:when test="$namespace = 'http://relaxng.org/ns/structure/1.0'">rng</xsl:when>
      <xsl:otherwise>tei</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Build a plain-text list of tag names which should be defined by CETEIcean. 
    When loaded by the browser, Javascript will interpret this list as an array. -->
  <xsl:template name="list-tags">
    <xsl:text>[</xsl:text>
    <xsl:for-each select="//*">
      <xsl:variable name="prefix">
        <xsl:call-template name="get-prefix"/>
      </xsl:variable>
      <xsl:text>"</xsl:text>
      <xsl:value-of select="$prefix"/>
      <xsl:text>:</xsl:text>
      <xsl:value-of select="local-name(.)"/>
      <xsl:text>"</xsl:text>
      <xsl:if test="not(position() = last())">
        <xsl:text>, </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>]</xsl:text>
  </xsl:template>
  
  <!-- Check the XSLT processor vendor to determine whether the HTML5 DOCTYPE will 
    be output. If not, write out the DOCTYPE in plain text. -->
  <xsl:template name="test-html5-output-support">
    <xsl:variable name="vendorName" select="system-property('xsl:vendor')"/>
    <xsl:variable name="canOutputHTML5">
      <xsl:choose>
        <xsl:when test="$vendorName = 'Saxonica'">
          <xsl:copy-of select="true()"/>
        </xsl:when>
        <xsl:when test="$vendorName = 'libxslt'">
          <xsl:copy-of select="true()"/><!-- TODO: test this -->
        </xsl:when>
        <!-- TransforMiiX is the processor used in Mozilla products (e.g. Firefox). 
          The processor does not support //xsl:text/@disable-output-escaping. 
          (https://developer.mozilla.org/en-US/docs/Web/API/XSLTProcessor/XSL_Transformations_in_Mozilla_FAQ)
          Luckily, there seems to be support for HTML5 output, but I haven't tested 
          this. -->
        <xsl:when test="$vendorName = 'Transformiix'">
          <xsl:copy-of select="true()"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="false()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="not($canOutputHTML5)">
      <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML&gt;</xsl:text>
      <xsl:text>&#x0A;</xsl:text>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
