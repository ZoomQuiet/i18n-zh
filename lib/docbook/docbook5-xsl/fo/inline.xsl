<?xml version='1.0'?>
<!DOCTYPE xsl:stylesheet [
  <!ENTITY comment.block.parents "parent::answer|parent::appendix|parent::article|parent::bibliodiv|
                                  parent::bibliography|parent::blockquote|parent::caution|parent::chapter|
                                  parent::glossary|parent::glossdiv|parent::important|parent::index|
                                  parent::indexdiv|parent::listitem|parent::note|parent::orderedlist|
                                  parent::partintro|parent::preface|parent::procedure|parent::qandadiv|
                                  parent::qandaset|parent::question|parent::refentry|parent::refnamediv|
                                  parent::refsect1|parent::refsect2|parent::refsect3|parent::refsection|
                                  parent::refsynopsisdiv|parent::sect1|parent::sect2|parent::sect3|parent::sect4|
                                  parent::sect5|parent::section|parent::setindex|parent::sidebar|
                                  parent::simplesect|parent::taskprerequisites|parent::taskrelated|
                                  parent::tasksummary|parent::warning">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://docbook.org/ns/docbook"
xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xlink='http://www.w3.org/1999/xlink'
                exclude-result-prefixes="xlink d"
                version='1.0'>

<!-- ********************************************************************
     $Id: inline.xsl 9 2007-04-05 08:11:11Z dongsheng.song $
     ********************************************************************

     This file is part of the XSL DocBook Stylesheet distribution.
     See ../README or http://nwalsh.com/docbook/xsl/ for copyright
     and other information.

     ******************************************************************** -->

<xsl:template name="simple.xlink">
  <xsl:param name="node" select="."/>
  <xsl:param name="content">
    <xsl:apply-templates/>
  </xsl:param>
  <xsl:param name="linkend" select="$node/@linkend"/>
  <xsl:param name="xhref" select="$node/@xlink:href"/>

  <xsl:choose>
    <xsl:when test="$xhref
                    and (not($node/@xlink:type) or 
                         $node/@xlink:type='simple')">

      <!-- Is it a local idref or a uri? -->
      <xsl:variable name="is.idref">
        <xsl:choose>
          <!-- if the href starts with # and does not contain an "(" -->
          <!-- or if the href starts with #xpointer(id(, it's just an ID -->
          <xsl:when test="starts-with($xhref,'#')
                          and (not(contains($xhref,'&#40;'))
                          or starts-with($xhref,
                                     '#xpointer&#40;id&#40;'))">1</xsl:when>
          <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="$is.idref = 1">

          <xsl:variable name="idref">
            <xsl:call-template name="xpointer.idref">
              <xsl:with-param name="xpointer" select="$xhref"/>
            </xsl:call-template>
          </xsl:variable>

          <xsl:variable name="targets" select="key('id',$idref)"/>
          <xsl:variable name="target" select="$targets[1]"/>

          <xsl:call-template name="check.id.unique">
            <xsl:with-param name="linkend" select="$idref"/>
          </xsl:call-template>

          <xsl:choose>
            <xsl:when test="count($target) = 0">
              <xsl:message>
                <xsl:text>XLink to nonexistent id: </xsl:text>
                <xsl:value-of select="$idref"/>
              </xsl:message>
              <xsl:copy-of select="$content"/>
            </xsl:when>

            <xsl:otherwise>
              <fo:basic-link internal-destination="{$idref}">
                <xsl:copy-of select="$content"/>
              </fo:basic-link>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>

        <!-- otherwise it's a URI -->
        <xsl:otherwise>
          <fo:basic-link external-destination="url({$xhref})">
            <xsl:copy-of select="$content"/>
          </fo:basic-link>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:when test="$linkend">
      <xsl:variable name="targets" select="key('id',$linkend)"/>
      <xsl:variable name="target" select="$targets[1]"/>

      <xsl:call-template name="check.id.unique">
        <xsl:with-param name="linkend" select="$linkend"/>
      </xsl:call-template>

      <xsl:choose>
        <xsl:when test="count($target) = 0">
          <xsl:message>
            <xsl:text>XLink to nonexistent id: </xsl:text>
            <xsl:value-of select="$linkend"/>
          </xsl:message>
          <xsl:copy-of select="$content"/>
        </xsl:when>

        <xsl:otherwise>
          <fo:basic-link internal-destination="{$linkend}">
            <xsl:copy-of select="$content"/>
          </fo:basic-link>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:otherwise>
      <xsl:copy-of select="$content"/>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template name="inline.charseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <xsl:choose>
    <xsl:when test="@dir">
      <fo:inline>
        <xsl:attribute name="direction">
          <xsl:choose>
            <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
            <xsl:otherwise>rtl</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:copy-of select="$content"/>
      </fo:inline>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$content"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="inline.monoseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline xsl:use-attribute-sets="monospace.properties">
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.boldseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline font-weight="bold">
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.italicseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline font-style="italic">
    <xsl:call-template name="anchor"/>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.boldmonoseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline font-weight="bold" xsl:use-attribute-sets="monospace.properties">
    <xsl:call-template name="anchor"/>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.italicmonoseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline font-style="italic" xsl:use-attribute-sets="monospace.properties">
    <xsl:call-template name="anchor"/>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.superscriptseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline xsl:use-attribute-sets="superscript.properties">
    <xsl:call-template name="anchor"/>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$fop.extensions != 0">
        <xsl:attribute name="vertical-align">super</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="baseline-shift">super</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<xsl:template name="inline.subscriptseq">
  <xsl:param name="content">
    <xsl:call-template name="simple.xlink">
      <xsl:with-param name="content">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:param>

  <fo:inline xsl:use-attribute-sets="subscript.properties">
    <xsl:call-template name="anchor"/>
    <xsl:if test="@dir">
      <xsl:attribute name="direction">
        <xsl:choose>
          <xsl:when test="@dir = 'ltr' or @dir = 'lro'">ltr</xsl:when>
          <xsl:otherwise>rtl</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$fop.extensions != 0">
        <xsl:attribute name="vertical-align">sub</xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="baseline-shift">sub</xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:copy-of select="$content"/>
  </fo:inline>
</xsl:template>

<!-- ==================================================================== -->
<!-- some special cases -->

<xsl:template match="d:author">
  <xsl:call-template name="simple.xlink">
    <xsl:with-param name="content">
      <xsl:call-template name="person.name"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:editor">
  <xsl:call-template name="simple.xlink">
    <xsl:with-param name="content">
      <xsl:call-template name="person.name"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:othercredit">
  <xsl:call-template name="simple.xlink">
    <xsl:with-param name="content">
      <xsl:call-template name="person.name"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:authorinitials">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:accel">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:action">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:application">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:classname">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:exceptionname">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:interfacename">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:methodname">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:command">
  <xsl:call-template name="inline.boldseq"/>
</xsl:template>

<xsl:template match="d:computeroutput">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:constant">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:database">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:date">
  <!-- should this support locale-specific formatting? how? -->
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:errorcode">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:errorname">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:errortype">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:errortext">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:envar">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:filename">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:function">
  <xsl:choose>
    <xsl:when test="$function.parens != '0'
                    and (d:parameter or d:function or d:replaceable)">
      <xsl:variable name="nodes" select="text()|*"/>
      <xsl:call-template name="inline.monoseq">
        <xsl:with-param name="content">
          <xsl:call-template name="simple.xlink">
            <xsl:with-param name="content">
              <xsl:apply-templates select="$nodes[1]"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="$nodes[position()>1]"/>
      <xsl:text>)</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     <xsl:call-template name="inline.monoseq"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="d:function/d:parameter" priority="2">
  <xsl:call-template name="inline.italicmonoseq"/>
  <xsl:if test="following-sibling::*">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="d:function/d:replaceable" priority="2">
  <xsl:call-template name="inline.italicmonoseq"/>
  <xsl:if test="following-sibling::*">
    <xsl:text>, </xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="d:guibutton">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:guiicon">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:guilabel">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:guimenu">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:guimenuitem">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:guisubmenu">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:hardware">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:interface">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:interfacedefinition">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:keycap">
  <xsl:call-template name="inline.boldseq"/>
</xsl:template>

<xsl:template match="d:keycode">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:keysym">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:literal">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:code">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:medialabel">
  <xsl:call-template name="inline.italicseq"/>
</xsl:template>

<xsl:template match="d:shortcut">
  <xsl:call-template name="inline.boldseq"/>
</xsl:template>

<xsl:template match="d:mousebutton">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:option">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:package">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:parameter">
  <xsl:call-template name="inline.italicmonoseq"/>
</xsl:template>

<xsl:template match="d:property">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:prompt">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:replaceable">
  <xsl:call-template name="inline.italicmonoseq"/>
</xsl:template>

<xsl:template match="d:returnvalue">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:structfield">
  <xsl:call-template name="inline.italicmonoseq"/>
</xsl:template>

<xsl:template match="d:structname">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:symbol">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:systemitem">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:token">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:type">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:userinput">
  <xsl:call-template name="inline.boldmonoseq"/>
</xsl:template>

<xsl:template match="d:abbrev">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:acronym">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:citerefentry">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:citetitle">
  <xsl:choose>
    <xsl:when test="@pubwork = 'article'">
      <xsl:call-template name="gentext.startquote"/>
      <xsl:call-template name="inline.charseq"/>
      <xsl:call-template name="gentext.endquote"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="inline.italicseq"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="d:emphasis">
  <xsl:variable name="depth">
    <xsl:call-template name="dot.count">
      <xsl:with-param name="string">
        <xsl:number level="multiple"/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="@role='bold' or @role='strong'">
      <xsl:call-template name="inline.boldseq"/>
    </xsl:when>
    <xsl:when test="@role='underline'">
      <fo:inline text-decoration="underline">
        <xsl:call-template name="inline.charseq"/>
      </fo:inline>
    </xsl:when>
    <xsl:when test="@role='strikethrough'">
      <fo:inline text-decoration="line-through">
        <xsl:call-template name="inline.charseq"/>
      </fo:inline>
    </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="$depth mod 2 = 1">
          <fo:inline font-style="normal">
            <xsl:apply-templates/>
          </fo:inline>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="inline.italicseq"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="d:foreignphrase">
  <xsl:call-template name="inline.italicseq"/>
</xsl:template>

<xsl:template match="d:markup">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:phrase">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:quote">
  <xsl:variable name="depth">
    <xsl:call-template name="dot.count">
      <xsl:with-param name="string"><xsl:number level="multiple"/></xsl:with-param>
    </xsl:call-template>
  </xsl:variable>
  <xsl:choose>
    <xsl:when test="$depth mod 2 = 0">
      <xsl:call-template name="gentext.startquote"/>
      <xsl:call-template name="inline.charseq"/>
      <xsl:call-template name="gentext.endquote"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="gentext.nestedstartquote"/>
      <xsl:call-template name="inline.charseq"/>
      <xsl:call-template name="gentext.nestedendquote"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="d:varname">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<xsl:template match="d:wordasword">
  <xsl:call-template name="inline.italicseq"/>
</xsl:template>

<xsl:template match="d:lineannotation">
  <fo:inline font-style="italic">
    <xsl:call-template name="inline.charseq"/>
  </fo:inline>
</xsl:template>

<xsl:template match="d:superscript">
  <xsl:call-template name="inline.superscriptseq"/>
</xsl:template>

<xsl:template match="d:subscript">
  <xsl:call-template name="inline.subscriptseq"/>
</xsl:template>

<xsl:template match="d:trademark">
  <xsl:call-template name="inline.charseq"/>
  <xsl:choose>
    <xsl:when test="@class = 'copyright'
                    or @class = 'registered'">
      <xsl:call-template name="dingbat">
        <xsl:with-param name="dingbat" select="@class"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="@class = 'service'">
      <xsl:call-template name="inline.superscriptseq">
        <xsl:with-param name="content" select="'SM'"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="dingbat">
        <xsl:with-param name="dingbat" select="'trademark'"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="d:firstterm">
  <xsl:call-template name="glossterm">
    <xsl:with-param name="firstterm" select="1"/>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:glossterm" name="glossterm">
  <xsl:param name="firstterm" select="0"/>

  <xsl:choose>
    <xsl:when test="($firstterm.only.link = 0 or $firstterm = 1) and @linkend">
      <xsl:variable name="targets" select="key('id',@linkend)"/>
      <xsl:variable name="target" select="$targets[1]"/>

      <xsl:choose>
        <xsl:when test="$target">
          <fo:basic-link internal-destination="{@linkend}" 
                         xsl:use-attribute-sets="xref.properties">
            <xsl:call-template name="inline.italicseq"/>
          </fo:basic-link>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="inline.italicseq"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:when test="not(@linkend)
                    and ($firstterm.only.link = 0 or $firstterm = 1)
                    and ($glossterm.auto.link != 0)
                    and $glossary.collection != ''">
      <xsl:variable name="term">
        <xsl:choose>
          <xsl:when test="@baseform"><xsl:value-of select="@baseform"/></xsl:when>
          <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="cterm"
           select="(document($glossary.collection,.)//d:glossentry[d:glossterm=$term])[1]"/>

      <xsl:choose>
        <xsl:when test="not($cterm)">
          <xsl:message>
            <xsl:text>There's no entry for </xsl:text>
            <xsl:value-of select="$term"/>
            <xsl:text> in </xsl:text>
            <xsl:value-of select="$glossary.collection"/>
          </xsl:message>
          <xsl:call-template name="inline.italicseq"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="id">
            <xsl:call-template name="object.id">
              <xsl:with-param name="object" select="$cterm"/>
            </xsl:call-template>
          </xsl:variable>
          <fo:basic-link internal-destination="{$id}"
                         xsl:use-attribute-sets="xref.properties">
            <xsl:call-template name="inline.italicseq"/>
          </fo:basic-link>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>

    <xsl:when test="not(@linkend)
                    and ($firstterm.only.link = 0 or $firstterm = 1)
                    and $glossterm.auto.link != 0">
      <xsl:variable name="term">
        <xsl:choose>
          <xsl:when test="@baseform">
            <xsl:value-of select="@baseform"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="targets"
                    select="//d:glossentry[d:glossterm=$term or d:glossterm/@baseform=$term]"/>

      <xsl:variable name="target" select="$targets[1]"/>

      <xsl:choose>
        <xsl:when test="count($targets)=0">
          <xsl:message>
            <xsl:text>Error: no glossentry for glossterm: </xsl:text>
            <xsl:value-of select="."/>
            <xsl:text>.</xsl:text>
          </xsl:message>
          <xsl:call-template name="inline.italicseq"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="termid">
            <xsl:call-template name="object.id">
              <xsl:with-param name="object" select="$target"/>
            </xsl:call-template>
          </xsl:variable>

          <fo:basic-link internal-destination="{$termid}"
                         xsl:use-attribute-sets="xref.properties">
            <xsl:call-template name="inline.charseq"/>
          </fo:basic-link>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="inline.italicseq"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="d:termdef">
  <fo:inline>
    <xsl:call-template name="gentext.template">
      <xsl:with-param name="context" select="'termdef'"/>
      <xsl:with-param name="name" select="'prefix'"/>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:call-template name="gentext.template">
      <xsl:with-param name="context" select="'termdef'"/>
      <xsl:with-param name="name" select="'suffix'"/>
    </xsl:call-template>
  </fo:inline>
</xsl:template>

<xsl:template match="d:sgmltag|d:tag">
  <xsl:variable name="class">
    <xsl:choose>
      <xsl:when test="@class">
        <xsl:value-of select="@class"/>
      </xsl:when>
      <xsl:otherwise>element</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$class='attribute'">
      <xsl:call-template name="inline.monoseq"/>
    </xsl:when>
    <xsl:when test="$class='attvalue'">
      <xsl:call-template name="inline.monoseq"/>
    </xsl:when>
    <xsl:when test="$class='element'">
      <xsl:call-template name="inline.monoseq"/>
    </xsl:when>
    <xsl:when test="$class='endtag'">
      <xsl:call-template name="inline.monoseq">
        <xsl:with-param name="content">
          <xsl:text>&lt;/</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>&gt;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$class='genentity'">
      <xsl:call-template name="inline.monoseq">
        <xsl:with-param name="content">
          <xsl:text>&amp;</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$class='numcharref'">
      <xsl:call-template name="inline.monoseq">
        <xsl:with-param name="content">
          <xsl:text>&amp;#</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$class='paramentity'">
      <xsl:call-template name="inline.monoseq">
        <xsl:with-param name="content">
          <xsl:text>%</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$class='pi'">
      <xsl:call-template name="inline.monoseq">
        <xsl:with-param name="content">
          <xsl:text>&lt;?</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>&gt;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$class='xmlpi'">
      <xsl:call-template name="inline.monoseq">
        <xsl:with-param name="content">
          <xsl:text>&lt;?</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>?&gt;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$class='starttag'">
      <xsl:call-template name="inline.monoseq">
        <xsl:with-param name="content">
          <xsl:text>&lt;</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>&gt;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$class='emptytag'">
      <xsl:call-template name="inline.monoseq">
        <xsl:with-param name="content">
          <xsl:text>&lt;</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>/&gt;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="$class='sgmlcomment' or $class='comment'">
      <xsl:call-template name="inline.monoseq">
        <xsl:with-param name="content">
          <xsl:text>&lt;!--</xsl:text>
          <xsl:apply-templates/>
          <xsl:text>--&gt;</xsl:text>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="inline.charseq"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="d:email">
  <xsl:call-template name="inline.monoseq">
    <xsl:with-param name="content">
      <fo:inline keep-together.within-line="always" hyphenate="false">
        <xsl:if test="not($email.delimiters.enabled = 0)">
          <xsl:text>&lt;</xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="not($email.delimiters.enabled = 0)">
          <xsl:text>&gt;</xsl:text>
        </xsl:if>
      </fo:inline>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:keycombo">
  <xsl:variable name="action" select="@action"/>
  <xsl:variable name="joinchar">
    <xsl:choose>
      <xsl:when test="$action='seq'"><xsl:text> </xsl:text></xsl:when>
      <xsl:when test="$action='simul'">+</xsl:when>
      <xsl:when test="$action='press'">-</xsl:when>
      <xsl:when test="$action='click'">-</xsl:when>
      <xsl:when test="$action='double-click'">-</xsl:when>
      <xsl:when test="$action='other'"></xsl:when>
      <xsl:otherwise>-</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:for-each select="*">
    <xsl:if test="position()>1"><xsl:value-of select="$joinchar"/></xsl:if>
    <xsl:apply-templates select="."/>
  </xsl:for-each>
</xsl:template>

<xsl:template match="d:uri">
  <xsl:call-template name="inline.monoseq"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:menuchoice">
  <xsl:variable name="shortcut" select="./d:shortcut"/>
  <xsl:call-template name="process.menuchoice"/>
  <xsl:if test="$shortcut">
    <xsl:text> (</xsl:text>
    <xsl:apply-templates select="$shortcut"/>
    <xsl:text>)</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="process.menuchoice">
  <xsl:param name="nodelist" select="d:guibutton|d:guiicon|d:guilabel|d:guimenu|d:guimenuitem|d:guisubmenu|d:interface"/><!-- not(shortcut) -->
  <xsl:param name="count" select="1"/>

  <xsl:variable name="mm.separator">
    <xsl:choose>
      <xsl:when test="$fop.extensions != 0 and
                contains($menuchoice.menu.separator, '&#x2192;')">
        <fo:inline font-family="Symbol">
          <xsl:copy-of select="$menuchoice.menu.separator"/>
        </fo:inline>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$menuchoice.menu.separator"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$count>count($nodelist)"></xsl:when>
    <xsl:when test="$count=1">
      <xsl:apply-templates select="$nodelist[$count=position()]"/>
      <xsl:call-template name="process.menuchoice">
        <xsl:with-param name="nodelist" select="$nodelist"/>
        <xsl:with-param name="count" select="$count+1"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:variable name="node" select="$nodelist[$count=position()]"/>
      <xsl:choose>
        <xsl:when test="local-name($node)='guimenuitem'
                        or local-name($node)='guisubmenu'">
          <xsl:copy-of select="$mm.separator"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$menuchoice.separator"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="$node"/>
      <xsl:call-template name="process.menuchoice">
        <xsl:with-param name="nodelist" select="$nodelist"/>
        <xsl:with-param name="count" select="$count+1"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:optional">
  <xsl:value-of select="$arg.choice.opt.open.str"/>
  <xsl:call-template name="inline.charseq"/>
  <xsl:value-of select="$arg.choice.opt.close.str"/>
</xsl:template>

<xsl:template match="d:citation">
  <!-- todo: integrate with bibliography collection -->
  <xsl:variable name="targets" select="(//d:biblioentry | //d:bibliomixed)[d:abbrev = string(current())]"/>
  <xsl:variable name="target" select="$targets[1]"/>

  <xsl:choose>
    <!-- try automatic linking based on match to abbrev -->
    <xsl:when test="$target and not(d:xref) and not(d:link)">

      <xsl:text>[</xsl:text>
      <fo:basic-link>
        <xsl:attribute name="internal-destination">
          <xsl:call-template name="object.id">
            <xsl:with-param name="object" select="$target"/>
          </xsl:call-template>
        </xsl:attribute>

        <xsl:call-template name="inline.charseq"/>
      </fo:basic-link>
      <xsl:text>]</xsl:text>
    </xsl:when>

    <xsl:otherwise>
      <xsl:text>[</xsl:text>
      <xsl:call-template name="inline.charseq"/>
      <xsl:text>]</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:comment[&comment.block.parents;]|d:remark[&comment.block.parents;]">
  <xsl:if test="$show.comments != 0">
    <fo:block font-style="italic">
      <xsl:call-template name="inline.charseq"/>
    </fo:block>
  </xsl:if>
</xsl:template>

<xsl:template match="d:comment|d:remark">
  <xsl:if test="$show.comments != 0">
    <fo:inline font-style="italic">
      <xsl:call-template name="inline.charseq"/>
    </fo:inline>
  </xsl:if>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:productname">
  <xsl:call-template name="inline.charseq"/>
  <xsl:if test="@class">
    <xsl:call-template name="dingbat">
      <xsl:with-param name="dingbat" select="@class"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="d:productnumber">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:pob|d:street|d:city|d:state|d:postcode|d:country|d:otheraddr">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:phone|d:fax">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<!-- in Addresses, for example -->
<xsl:template match="d:honorific|d:firstname|d:surname|d:lineage|d:othername">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:personname">
  <xsl:call-template name="simple.xlink">
    <xsl:with-param name="content">
      <xsl:call-template name="person.name"/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="d:jobtitle">
  <xsl:call-template name="simple.xlink">
    <xsl:with-param name="content">
      <xsl:apply-templates/>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:org">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:orgname">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:orgdiv">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<xsl:template match="d:affiliation">
  <xsl:call-template name="inline.charseq"/>
</xsl:template>

<!-- ==================================================================== -->

<xsl:template match="d:beginpage">
  <!-- does nothing; this *is not* markup to force a page break. -->
</xsl:template>

</xsl:stylesheet>

