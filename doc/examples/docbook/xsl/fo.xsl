<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version='1.0'>

  <xsl:import href="../../../../lib/docbook/docbook-xsl/fo/docbook.xsl"/>

  <xsl:param name="l10n.gentext.language" select="'en'"/>

  <xsl:param name="paper.type" select="'A4'"></xsl:param>

  <!-- These extensions are required for table printing and other stuff -->
  <xsl:param name="use.extensions">1</xsl:param>
  <xsl:param name="tablecolumns.extension">0</xsl:param>
  <xsl:param name="fop.extensions">0</xsl:param>
  <xsl:param name="fop1.extensions">1</xsl:param>

  <xsl:param name="draft.mode" select="no"/>

  <xsl:param name="variablelist.as.blocks" select="1" />
  <xsl:param name="admon.textlabel" select="0" />
  <xsl:param name="admon.graphics" select="1" />
  <xsl:param name="admon.graphics.path">images/</xsl:param>
  <xsl:param name="admon.graphics.extension">.png</xsl:param>
  <xsl:param name="section.autolabel" select="1" />
  <xsl:attribute-set name="sidebar.properties" use-attribute-sets="formal.object.properties">
    <xsl:attribute name="border-style">solid</xsl:attribute>
    <xsl:attribute name="border-width">.1mm</xsl:attribute>
    <xsl:attribute name="background-color">#EEEEEE</xsl:attribute>
  </xsl:attribute-set>

  <!-- Prevent blank pages in output -->
  <xsl:template name="book.titlepage.before.verso">
  </xsl:template>
  <xsl:template name="book.titlepage.verso">
  </xsl:template>
  <xsl:template name="book.titlepage.separator">
  </xsl:template>

  <!-- Font related Settings -->
  <xsl:param name="title.font.family">Arial,Calibri,sans-serif,SimHei</xsl:param>
  <xsl:param name="body.font.family">Times New Roman,Cambria,Cambria Math,serif,SimSun</xsl:param>
  <xsl:param name="sans.font.family">Arial,Calibri,sans-serif,SimHei</xsl:param>
  <xsl:param name="dingbat.font.family">Times New Roman,Cambria,Cambria Math,serif,SimSun</xsl:param>
  <xsl:param name="monospace.font.family">Courier New,monospace,FangSong</xsl:param>

</xsl:stylesheet>
