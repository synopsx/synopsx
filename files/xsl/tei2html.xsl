<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">
	<xsl:output method="xml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
	<xsl:strip-space elements="*"/>
	<!--
	     group
	     text
	     front
	     body
	     div
	     back
	     space
	     metamark
	     
	     titlePage
	     docTitle
	     titlePart
	     docImprint
	     docDate
	     imprimatur
	     pubPlace
	     publisher
	     
	     persName
	     orgName
	     placeName
	     geogName
	     objectName
	     abbr
	     expan
	     fw
	     gap
	     rs
	     ref
	     date
	     num
	     cb
	     supplied
	     unclear
	     surplus
	     sic
	     orig
	     reg
	     soCalled
	     title
	     bibl
	     label
	     lg
	     l
	     graphic
	     figure
	     desc
	     seg
	     note -->
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="teiHeader"/>
	<xsl:template match="TEI">
		<xsl:apply-templates/>
	</xsl:template>
	<!-- liens et pointeurs -->
	<xsl:template match="ptr[@target]">
		<a href="{@target}">
			<xsl:apply-templates select="@*"/>
			<!--<xsl:call-template name="rendition"/>-->
			<xsl:value-of select="normalize-space(@target)"/>
		</a>
	</xsl:template>
	<!-- conversion des attributs @xmlid en @id -->
	<xsl:template match="@xml:id">
		<xsl:attribute name="id">
			<xsl:value-of select="."/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="@xml:lang">
		<xsl:attribute name="class">
			<xsl:value-of select="."/>
		</xsl:attribute>
		<!-- TODO quid lors de la création de plusieurs valeurs de @class -->
	</xsl:template>

	<!-- sauts de ligne et pagination -->
	<xsl:template match="lb">
		<br class="lb"/>
	</xsl:template>
	<xsl:template match="pb">
		<span>
			<xsl:apply-templates select="@*"/>
		</span>
	</xsl:template>
	<!-- titres et divisions -->
	<xsl:template match="text">
		<section class="{local-name()}">
			<xsl:apply-templates />
		</section>
	</xsl:template>
	<xsl:template match="front | body | back">
		<section class="{local-name()}">
			<xsl:apply-templates select="@*|node()"/>
		</section>
	</xsl:template>
	<xsl:template match="front/div[@xml:lang] | body/div[@xml:lang] | back/div[@xml:lang]">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="titlePage">
		<header>
			<xsl:apply-templates />
		</header>
	</xsl:template>
	<xsl:template match="docTitle">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="titlePart">
		<h1>
			<xsl:apply-templates />
		</h1>
	</xsl:template>
	<xsl:template match="docAuthor | docDate | docEdition">
		<span class="{local-name()}">
			<xsl:apply-templates />
		</span>
	</xsl:template>
	<xsl:template match="div | p">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<xsl:template match="head">
		<xsl:variable name="level" select="count(ancestor::div)"/>
		<xsl:variable name="name" select="concat('h', $level)"/>
		<xsl:element name="{$name}">
			<xsl:apply-templates />
		</xsl:element>
	</xsl:template>
	<!-- listes -->
	<xsl:template match="list[@type='ordered']">
		<ol>
			<xsl:apply-templates/>
		</ol>
	</xsl:template>
	<xsl:template match="list[@type='definition']">
		<dl>
			<xsl:apply-templates mode="definition"/>
		</dl>
	</xsl:template>
	<xsl:template match="list">
		<ul>
			<xsl:apply-templates />
		</ul>
	</xsl:template>
	<xsl:template match="item/label">
		<span>
			<xsl:apply-templates />
		</span>
	</xsl:template>

	<xsl:template match="item">
		<li>
			<xsl:apply-templates />
		</li>
	</xsl:template>
	<xsl:template match="item" mode="definition">
		<dt>
			<xsl:apply-templates />
		</dt>
	</xsl:template>
	<!-- citations -->
	<xsl:template match="quote[not(ancestor::p)]">
		<blockquote>
			<xsl:apply-templates />
		</blockquote>
	</xsl:template>
	<xsl:template match="quote/cit">
		<footer>
			<!-- TODO créer un lien lorsqu'une référence est fournie -->
			<cit>
				<xsl:apply-templates />
			</cit>
		</footer>
	</xsl:template>
	<!-- gap, etc. -->
	<xsl:template match="gap">
		<span class="{local-name()}">[…]</span>
	</xsl:template>
	<xsl:template match="supplied | unclear">
		<span class="{local-name()}">
			<xsl:text> [</xsl:text>
				<xsl:apply-templates/>
			<xsl:text>] </xsl:text>
		</span>
	</xsl:template>
	<xsl:template match="sic">
		<span class="{local-name()}">
			<xsl:apply-templates/>
			<xsl:text> [sic.]</xsl:text>
		</span>
	</xsl:template>
	<!-- éléments inline -->
	<xsl:template match="hi">
		<span class="{local-name()} {@rend}">
			<xsl:apply-templates />
		</span>
	</xsl:template>
	<xsl:template match="hi[@rend='bold']">
		<strong>
			<xsl:apply-templates/>
		</strong>
	</xsl:template>
	<xsl:template match="hi[@rend='italic']">
		<em>
			<xsl:apply-templates />
		</em>
	</xsl:template>
	<xsl:template match="hi[@rend='superscript']">
		<sup>
			<xsl:apply-templates/>
		</sup>
	</xsl:template>
	<xsl:template match="hi[@rend='underscript']">
		<sub>
			<xsl:apply-templates/>
		</sub>
	</xsl:template>

	<xsl:template match="foreign">
		<span class="{local-name()}">
			<xsl:apply-templates/>
		</span>
		<!-- TODO traiter les cas des éléments portant un @xml:lang -->
	</xsl:template>
	<xsl:template match="q | p/quote">
		<xsl:text>«&#160;</xsl:text>
			<xsl:apply-templates/>
		<xsl:text>&#160;»</xsl:text>
	</xsl:template>
	<!-- traitement des sources manuscrites -->
	<xsl:template match="del">
		<xsl:text>&#160;</xsl:text>
		<del>
			<xsl:apply-templates />
		</del>
		<xsl:text>&#160;</xsl:text>
	</xsl:template>
	<!-- biblio -->
	<xsl:template match="title">
		<xsl:apply-templates />
	</xsl:template>
	<!-- mentions de responsabilités -->
	<xsl:template match="principal">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="persName">
		<xsl:apply-templates select="forename"/>
		<xsl:apply-templates select="surname"/>
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="forename">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="surname">
		<xsl:apply-templates />
	</xsl:template>
	<!-- traitement par défaut -->
	<xsl:template match="@*">
		<xsl:copy/>
	</xsl:template>
	<!-- <xsl:template match="*"> 
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*"/>
           <!-/- <xsl:call-template name="addID"/>
            <xsl:call-template name="rendition"/>-/->
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template> -->
	<!--<xsl:template match="node()|@*" mode="#all">
		<xsl:copy>
			<xsl:apply-templates select="node()|@*" mode="#current"/>
		</xsl:copy>
	</xsl:template>-->
	<!-- normalisation des espaces (http://wiki.tei-c.org/index.php/XML_Whitespace) -->
	<xsl:template match="text()">
		<xsl:choose>
			<xsl:when
				test="ancestor::*[@xml:space][1]/@xml:space='preserve'">
				<xsl:value-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<!-- Retain one leading space if node isn't first, has non-space content, and has leading space.-->
				<xsl:if test="position()!=1 and matches(.,'^\s') and normalize-space()!=''">
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:choose>
					<!-- node is an only child, and has content but it's all space -->
					<xsl:when test="last()=1 and string-length()!=0 and normalize-space()=''">
						<xsl:text> </xsl:text>
					</xsl:when>
					<!-- node isn't last, isn't first, and has trailing space -->
					<xsl:when test="position()!=1 and position()!=last() and matches(.,'\s$')">
						<xsl:text> </xsl:text>
					</xsl:when>
					<!-- node isn't last, is first, has trailing space, and has non-space content -->
					<xsl:when test="position()=1 and matches(.,'\s$') and normalize-space()!=''">
						<xsl:text> </xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="table">
		<table>
			<xsl:apply-templates/>
		</table>
	</xsl:template>
	<xsl:template match="row">
		<tr>
			<xsl:apply-templates/>
		</tr>
	</xsl:template>
	<xsl:template match="cell">
		<td>
			<xsl:apply-templates/>
		</td>
	</xsl:template>
</xsl:stylesheet>
