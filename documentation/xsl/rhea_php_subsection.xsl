<?xml version='1.0'?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!--
	$Id$
	Copyright 2006, 2008 phpBB Group
	Licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 license
	http://creativecommons.org/licenses/by-nc-sa/3.0/
-->

<xsl:import href="xhtml/chunk.xsl"/>

<xsl:param name="base.dir" select="'./build/'"/>
<xsl:param name="html.ext" select="'.php'"/>

<!-- Link to the stylesheet -->
<xsl:param name="html.stylesheet" select="'/support/documentation/3.2/style.css'"/>

<xsl:param name="chunk.fast" select="1"/>
<!-- Do NOT add the first section into the starting chunk -->
<xsl:param name="chunk.first.sections" select="1"/>

<!-- Create a file for each subsection, too -->
<xsl:param name="chunk.section.depth" select="2"/>

<!-- Enumerate sections -->
<xsl:param name="section.autolabel" select="1"/>
<!-- Include numebers of the top elements -->
<xsl:param name="section.label.includes.component.label" select="1"/>

<!-- We use the section / chapter ids as filenames -->
<xsl:param name="use.id.as.filename" select="1"/>

<!-- TOC -->
<xsl:param name="toc.section.depth" select="4"/>

<!-- avoid short tag problems, no DOCTYPE as this is supposed to be in-page -->
<xsl:param name="chunker.output.omit-xml-declaration" select="'yes'"/>
<xsl:param name="chunker.output.doctype-public" select="''"/>
<xsl:param name="chunker.output.doctype-system" select="''"/>

<xsl:variable name="main.title.text" select="'phpBB 3.2 Rhea Documentation'"/>

<xsl:template name="user.preroot">

	<xsl:param name="node" select="."/>
	<xsl:param name="title">
		<xsl:apply-templates select="$node" mode="object.title.markup.textonly"/>
	</xsl:param>

	<xsl:text disable-output-escaping="yes">&lt;?php
		// The page title
		$page_title = '</xsl:text>

	<xsl:copy-of select="$title"/>

	<xsl:text disable-output-escaping="yes">';
// Paths
</xsl:text>

	<xsl:choose>
		<xsl:when test="$title = $main.title.text">
			<xsl:text>$root_path = './../../../';</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>$root_path = './../../../../';</xsl:text>
		</xsl:otherwise>
	</xsl:choose>

	<xsl:text disable-output-escaping="yes">
define('IN_PHPBB', true);

include($root_path . 'common.php');
include($root_path . 'includes/functions_docbook.php');

$template->set_filenames(array(
	'body'	=> 'support/support_documentation_docbook.html')
);

</xsl:text>
</xsl:template>


<xsl:template name="user.head.content">
	<xsl:if test="contains(system-property('xsl:vendor'), 'SAXON') or contains(system-property('xsl:vendor'), 'Apache')">
		<meta content="text/html; charset=UTF-8" http-equiv="Content-Type" xmlns="http://www.w3.org/1999/xhtml"/>
	</xsl:if>
</xsl:template>

<!-- Copyright -->
<xsl:template name="footer.navigation">
	<div class="copyright">&#x00A9; 2006, 2008 phpBB Group &#x2014; Licensed under the Creative Commons <a href="http://creativecommons.org/licenses/by-nc-sa/3.0/">Attribution-NonCommercial-ShareAlike 3.0</a> license</div>
	<xsl:text disable-output-escaping="yes">
&lt;?php

$content = str_replace(' xmlns="http://www.w3.org/1999/xhtml"', '', ob_get_clean());

$template->assign_vars(array(
	'PAGE_TITLE'		=> $page_title,
	'S_CONTENT'			=> $content,
	'S_BODY_CLASS'		=> 'support documentation docbook')
);

page_header($page_title, false);

page_footer(false);
?&gt;</xsl:text>
</xsl:template>

<!-- Prevent image links breaking on yavin -->
<xsl:template match="@fileref">
	<xsl:value-of select="."/>
</xsl:template>

<!-- A helper function (use docbook's string.subst?) -->
<xsl:template name="replace-string">
	<xsl:param name="text"/>
	<xsl:param name="replace"/>
	<xsl:param name="with"/>
	<xsl:choose>
		<xsl:when test="contains($text,$replace)">
			<xsl:value-of select="substring-before($text,$replace)"/>
			<xsl:value-of select="$with"/>
			<xsl:call-template name="replace-string">
				<xsl:with-param name="text"
		select="substring-after($text,$replace)"/>
				<xsl:with-param name="replace" select="$replace"/>
				<xsl:with-param name="with" select="$with"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$text"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!-- overwrite a few standard templates -->
<!-- original version: html.xsl -->
<xsl:template name="anchor">
  <xsl:param name="node" select="."/>
  <xsl:param name="conditional" select="1"/>
  <xsl:variable name="id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="$node"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:if test="$conditional = 0 or $node/@id">
    <span id="{$id}"/>
  </xsl:if>
</xsl:template>

<!-- original version: chunk-common.xsl -->
<xsl:template name="chunk-element-content">
	<xsl:param name="prev"/>
	<xsl:param name="next"/>
	<xsl:param name="nav.context"/>
	<xsl:param name="content">
		<xsl:apply-imports/>
	</xsl:param>

	<xsl:call-template name="user.preroot"/>

	<xsl:call-template name="body.attributes"/>

	<xsl:call-template name="header.navigation">
		<xsl:with-param name="prev" select="$prev"/>
		<xsl:with-param name="next" select="$next"/>
		<xsl:with-param name="nav.context" select="$nav.context"/>
	</xsl:call-template>

	<xsl:copy-of select="$content"/>

	<xsl:call-template name="footer.navigation">
		<xsl:with-param name="prev" select="$prev"/>
		<xsl:with-param name="next" select="$next"/>
		<xsl:with-param name="nav.context" select="$nav.context"/>
	</xsl:call-template>
</xsl:template>

<!-- original version: chunk-common.xsl - The only change here is the file renaming to php, maybe we can change the dbhtml definitions in the xml files instead of copying this whole template? -->
<xsl:template match="*" mode="recursive-chunk-filename">
  <xsl:param name="recursive" select="false()"/>

  <!-- returns the filename of a chunk -->
  <xsl:variable name="ischunk">
    <xsl:call-template name="chunk"/>
  </xsl:variable>

  <xsl:variable name="dbhtml-filename">
    <xsl:call-template name="dbhtml-filename"/>
  </xsl:variable>

  <xsl:variable name="filename">
    <xsl:choose>
      <xsl:when test="$dbhtml-filename != ''">
        <xsl:call-template name="replace-string">
          <xsl:with-param name="text" select="$dbhtml-filename"/>
          <xsl:with-param name="replace" select="'html'"/>
          <xsl:with-param name="with" select="'php'"/>
        </xsl:call-template>
      </xsl:when>
      <!-- if this is the root element, use the root.filename -->
      <xsl:when test="not(parent::*) and $root.filename != ''">
        <xsl:value-of select="$root.filename"/>
        <xsl:value-of select="$html.ext"/>
      </xsl:when>
      <!-- if there's no dbhtml filename, and if we're to use IDs as -->
      <!-- filenames, then use the ID to generate the filename. -->
      <xsl:when test="@id and $use.id.as.filename != 0">
        <xsl:value-of select="@id"/>
        <xsl:value-of select="$html.ext"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <xsl:when test="$ischunk='0'">
      <!-- if called on something that isn't a chunk, walk up... -->
      <xsl:choose>
        <xsl:when test="count(parent::*)&gt;0">
          <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
            <xsl:with-param name="recursive" select="$recursive"/>
          </xsl:apply-templates>
        </xsl:when>
        <!-- unless there is no up, in which case return "" -->
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:when>

    <xsl:when test="not($recursive) and $filename != ''">
      <!-- if this chunk has an explicit name, use it -->
      <xsl:value-of select="$filename"/>
    </xsl:when>

    <xsl:when test="self::set">
      <xsl:value-of select="$root.filename"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::book">
      <xsl:text>bk</xsl:text>
      <xsl:number level="any" format="01"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::article">
      <xsl:if test="/set">
        <!-- in a set, make sure we inherit the right book info... -->
        <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
          <xsl:with-param name="recursive" select="true()"/>
        </xsl:apply-templates>
      </xsl:if>

      <xsl:text>ar</xsl:text>
      <xsl:number level="any" format="01" from="book"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::preface">
      <xsl:if test="/set">
        <!-- in a set, make sure we inherit the right book info... -->
        <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
          <xsl:with-param name="recursive" select="true()"/>
        </xsl:apply-templates>
      </xsl:if>

      <xsl:text>pr</xsl:text>
      <xsl:number level="any" format="01" from="book"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::chapter">
      <xsl:if test="/set">
        <!-- in a set, make sure we inherit the right book info... -->
        <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
          <xsl:with-param name="recursive" select="true()"/>
        </xsl:apply-templates>
      </xsl:if>

      <xsl:text>ch</xsl:text>
      <xsl:number level="any" format="01" from="book"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::appendix">
      <xsl:if test="/set">
        <!-- in a set, make sure we inherit the right book info... -->
        <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
          <xsl:with-param name="recursive" select="true()"/>
        </xsl:apply-templates>
      </xsl:if>

      <xsl:text>ap</xsl:text>
      <xsl:number level="any" format="a" from="book"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::part">
      <xsl:choose>
        <xsl:when test="/set">
          <!-- in a set, make sure we inherit the right book info... -->
          <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:text>pt</xsl:text>
      <xsl:number level="any" format="01" from="book"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::reference">
      <xsl:choose>
        <xsl:when test="/set">
          <!-- in a set, make sure we inherit the right book info... -->
          <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:text>rn</xsl:text>
      <xsl:number level="any" format="01" from="book"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::refentry">
      <xsl:choose>
        <xsl:when test="parent::reference">
          <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:text>re</xsl:text>
      <xsl:number level="any" format="01" from="book"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::colophon">
      <xsl:choose>
        <xsl:when test="/set">
          <!-- in a set, make sure we inherit the right book info... -->
          <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:text>co</xsl:text>
      <xsl:number level="any" format="01" from="book"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::sect1                     or self::sect2                     or self::sect3                     or self::sect4                     or self::sect5                     or self::section">
      <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
        <xsl:with-param name="recursive" select="true()"/>
      </xsl:apply-templates>
      <xsl:text>s</xsl:text>
      <xsl:number format="01"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::bibliography">
      <xsl:choose>
        <xsl:when test="/set">
          <!-- in a set, make sure we inherit the right book info... -->
          <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:text>bi</xsl:text>
      <xsl:number level="any" format="01" from="book"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::glossary">
      <xsl:choose>
        <xsl:when test="/set">
          <!-- in a set, make sure we inherit the right book info... -->
          <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:text>go</xsl:text>
      <xsl:number level="any" format="01" from="book"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::index">
      <xsl:choose>
        <xsl:when test="/set">
          <!-- in a set, make sure we inherit the right book info... -->
          <xsl:apply-templates mode="recursive-chunk-filename" select="parent::*">
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:text>ix</xsl:text>
      <xsl:number level="any" format="01" from="book"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:when test="self::setindex">
      <xsl:text>si</xsl:text>
      <xsl:number level="any" format="01" from="set"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:when>

    <xsl:otherwise>
      <xsl:text>chunk-filename-error-</xsl:text>
      <xsl:value-of select="name(.)"/>
      <xsl:number level="any" format="01" from="set"/>
      <xsl:if test="not($recursive)">
        <xsl:value-of select="$html.ext"/>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- PHP navigation (original code by php.net) overwrites standard navigation -->
<xsl:template name="header.navigation">
	<xsl:param name="prev" select="/foo"/>
	<xsl:param name="next" select="/foo"/>
	<xsl:variable name="home" select="/*[1]"/>
	<xsl:variable name="up" select="parent::*"/>

	<xsl:variable name="titleclean">
		<xsl:apply-templates select="." mode="object.title.markup.textonly"/>
	</xsl:variable>

	<xsl:text disable-output-escaping="yes">$navigation = array(
	'home' =&gt; </xsl:text>

	<xsl:call-template name="phpdoc.nav.array">
		<xsl:with-param name="node" select="$home"/>
		<xsl:with-param name="currenttitle" select="$titleclean"/>
	</xsl:call-template>

	<xsl:text disable-output-escaping="yes">,
	'this' =&gt; </xsl:text>

	<xsl:call-template name="phpdoc.nav.array">
		<xsl:with-param name="node" select="."/>
		<xsl:with-param name="currenttitle" select="$titleclean"/>
	</xsl:call-template>

	<xsl:text disable-output-escaping="yes">,
	'prev' =&gt; </xsl:text>

	<xsl:call-template name="phpdoc.nav.array">
		<xsl:with-param name="node" select="$prev"/>
		<xsl:with-param name="currenttitle" select="$titleclean"/>
	</xsl:call-template>

	<xsl:text disable-output-escaping="yes">,
	'next' =&gt; </xsl:text>

	<xsl:call-template name="phpdoc.nav.array">
		<xsl:with-param name="node" select="$next"/>
		<xsl:with-param name="currenttitle" select="$titleclean"/>
	</xsl:call-template>

	<xsl:text disable-output-escaping="yes">,
	'up'   =&gt; </xsl:text>

	<xsl:call-template name="phpdoc.nav.array">
		<xsl:with-param name="node" select="$up"/>
		<xsl:with-param name="currenttitle" select="$titleclean"/>
	</xsl:call-template>

	<xsl:text disable-output-escaping="yes">,
	'toc'  =&gt; </xsl:text>

	<xsl:call-template name="header.recursive.toc">
		<xsl:with-param name="titleclean" select="$titleclean"/>
	</xsl:call-template>

	<xsl:text disable-output-escaping="yes">
);

docbook_navigation($navigation);

ob_start();
?&gt;</xsl:text>
	<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template name="header.recursive.toc">
	<xsl:param name="node" select="/"/>
	<xsl:param name="titleclean" select="''"/>

	<xsl:for-each select="$node/*">
		<xsl:variable name="ischunk"><xsl:call-template name="chunk"/></xsl:variable>
		<xsl:if test="$ischunk='1'">
			<xsl:text>array(</xsl:text>

			<xsl:call-template name="phpdoc.nav.array">
				<xsl:with-param name="node" select="."/>
				<xsl:with-param name="useabbrev" select="'1'"/>
				<xsl:with-param name="currenttitle" select="$titleclean"/>
				<xsl:with-param name="arraycode" select="'0'"/>
			</xsl:call-template>
			<xsl:text>,</xsl:text>

			<!-- recurse -->
			<xsl:text>array(</xsl:text>
			<xsl:call-template name="header.recursive.toc">
				<xsl:with-param name="node" select="."/>
				<xsl:with-param name="titleclean" select="$titleclean"/>
			</xsl:call-template>

			<xsl:text>)),
			</xsl:text>
		</xsl:if>
	</xsl:for-each>
</xsl:template>

<!-- Prints out one PHP array with page name and title -->
<xsl:template name="phpdoc.nav.array">
	<xsl:param name="node" select="/foo"/>
	<xsl:param name="useabbrev" select="'0'"/>
	<xsl:param name="currenttitle" select="''"/>
	<xsl:param name="arraycode" select="'1'"/>

	<!-- Get usual title -->
	<xsl:variable name="title">
		<xsl:apply-templates select="$node" mode="phpdoc.object.title"/>
	</xsl:variable>

	<!-- Compute titleabbrev value -->
	<xsl:variable name="titleabbrev">
		<xsl:if test="$useabbrev = '1' and string($node/titleabbrev) != ''">
			<xsl:value-of select="$node/titleabbrev" />
		</xsl:if>
	</xsl:variable>

	<!-- Print out PHP array -->
	<xsl:if test="$arraycode='1'">
		<xsl:text>array(</xsl:text>
	</xsl:if>
	<xsl:text>'</xsl:text>
	<xsl:if test="$currenttitle != $main.title.text">
		<xsl:text>../</xsl:text>
	</xsl:if>
	<xsl:call-template name="href.target.uri">
		<xsl:with-param name="object" select="$node"/>
	</xsl:call-template>
	<xsl:text>','</xsl:text>
	<!-- use the substring replace template defined in Docbook XSL's lib to escape apostrophes -->
	<xsl:call-template name="string.subst">
		<xsl:with-param name="string">
			<xsl:choose>
				<xsl:when test="$titleabbrev != ''">
					<xsl:value-of select="$titleabbrev"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$title"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:with-param>
		<xsl:with-param name="target" select='"&apos;"'/>
		<xsl:with-param name="replacement" select='"\&apos;"'/>
	</xsl:call-template>
	<xsl:text>'</xsl:text>
	<xsl:if test="$arraycode='1'">
		<xsl:text>)</xsl:text>
	</xsl:if>
</xsl:template>

<!-- Custom mode for titles for navigation without
     "Chapter 1" and other autogenerated content -->
<xsl:template match="*" mode="phpdoc.object.title">
 <xsl:call-template name="substitute-markup">
  <xsl:with-param name="allow-anchors" select="0"/>
  <xsl:with-param name="template" select="'%t'"/>
 </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
