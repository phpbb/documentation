<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="1.1"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xi="http://www.w3.org/2001/XInclude">

    <xsl:import
        href=".\pdf\fo\docbook.xsl" />

    <xsl:template match="xi:include">
		<xsl:apply-templates select="document(@href)/*" />
    </xsl:template>
	
	<xsl:param name="use.extensions" select="1"></xsl:param>
	<xsl:param name="graphicsize.extension" select="1"></xsl:param>
	<xsl:param name="paper.type" select="'USletter'"></xsl:param>
	<xsl:param name="section.autolabel" select="1"></xsl:param>
	<xsl:param name="toc.section.depth" select="3"></xsl:param>
	<xsl:param name="draft.mode" select="no"></xsl:param>
	
	<!-- xsl:param name="xep.extensions" select="1"></xsl:param -->
	<xsl:param name="fop1.extensions" select="1"></xsl:param>
	<xsl:param name="phpbb.suppress.authors" select="1"></xsl:param>
	<xsl:param name="phpbb.suppress.revision" select="1"></xsl:param>
	<xsl:param name="phpbb.suppress.chapterCopyright" select="1"></xsl:param>
</xsl:stylesheet>