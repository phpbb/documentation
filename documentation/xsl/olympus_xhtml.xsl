<?xml version='1.0'?>
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:import href="xhtml/chunk.xsl"/>

<!-- Link to the stylesheet -->
<xsl:param name="html.stylesheet" select="'/output/style.css'"/>

<xsl:param name="chunk.fast" select="1"/>
<!-- Do NOT add the first section into the starting chunk -->
<xsl:param name="chunk.first.sections" select="1"/>

<!-- Enumerate sections -->
<xsl:param name="section.autolabel" select="1"/>
<!-- Include numebers of the top elements -->
<xsl:param name="section.label.includes.component.label" select="1"/>

<!-- We use the section / chapter ids as filenames -->
<xsl:param name="use.id.as.filename" select="1"/>

<!-- TOC -->
<xsl:param name="toc.section.depth" select="4"/>

<xsl:template name="user.head.content">
  <xsl:if test="contains(system-property('xsl:vendor'), 
     'SAXON') or contains(system-property('xsl:vendor'), 'Apache')">
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"
      xmlns="http://www.w3.org/1999/xhtml"/>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>