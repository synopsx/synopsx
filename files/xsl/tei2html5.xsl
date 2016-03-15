<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    version="2.0">
    <!-- Transfos TEI  HTML5 courantes 
    Dont templates reprises de la xsl teiboilerplate ! 
    https://raw.github.com/GrantLS/TEI-Boilerplate/master/content/teibp.xsl
    -->
    
    <xsl:import href="tei2html.xsl"/>
    <xsl:template match="@xml:id">
        <!-- @xml:id is copied to @id, which browsers can use
			for internal links.
		-->
        <!--
		<xsl:attribute name="xml:id">
			<xsl:value-of select="."/>
		</xsl:attribute>
		-->
        <xsl:attribute name="id">
            <xsl:value-of select="."/>
        </xsl:attribute>
    </xsl:template>
    
    <xd:doc>
    <xd:desc>
        <xd:p>Basic copy template, copies all attribute nodes from source XML tree to output
            document.</xd:p>
    </xd:desc>
    </xd:doc>
    <xsl:template match="@*">
        <xsl:copy/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Template for elements, which handles style and adds an @xml:id to every element.
                Existing @xml:id attributes are retained unchanged.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="*"> 
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@*"/>
           <!-- <xsl:call-template name="addID"/>
            <xsl:call-template name="rendition"/>-->
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Transforms TEI ref element to html a (link) element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="*[local-name() = 'ref'][@target]" priority="99">
        <a href="{@target}">
            <xsl:apply-templates select="@*"/>
            <!--<xsl:call-template name="rendition"/>-->
            <xsl:apply-templates select="node()"/>
        </a>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Transforms TEI ptr element to html a (link) element.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="*[local-name() = 'ptr'][@target]" priority="99">
        <a href="{@target}">
            <xsl:apply-templates select="@*"/>
            <!--<xsl:call-template name="rendition"/>-->
            <xsl:value-of select="normalize-space(@target)"/>
        </a>
    </xsl:template>
    
    
    <xsl:template match="*[local-name() = 'del']">
        <xsl:text>&#160;</xsl:text><del><xsl:apply-templates/></del><xsl:text>&#160;</xsl:text>
    </xsl:template>
    
    
    <xsl:template match="*[local-name() = 'head']">
        <xsl:variable name="level" select="count(ancestor::*[local-name()='div'])" />
        <xsl:variable name="name" select="concat('h', $level)" />
        <xsl:element name="{$name}"><xsl:apply-templates select="@*|node()"/></xsl:element>
    </xsl:template>
    
    
    <xsl:template match="*[local-name() = 'lb']">
        <br />
    </xsl:template>
    
    
    <xsl:template match="*[local-name() = 'list']">
        <xsl:choose>
            <xsl:when test="@type='ordered'">
                <ol>
                    <xsl:apply-templates/>
                </ol>
            </xsl:when>
            <xsl:when test="@type='definition'">
                <dl>
                    <xsl:apply-templates mode="definition"/>
                </dl>
            </xsl:when>
            <xsl:otherwise>
                <ul>
                    <xsl:apply-templates/>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[local-name() = 'item']">
        <li><xsl:apply-templates/></li>
    </xsl:template>
    
    <xsl:template match="*[local-name() = 'item']" mode="definition">
        <dt><xsl:apply-templates/></dt>
    </xsl:template>
    
    
    <xsl:template match="*[local-name() = 'note']">
        <sup><a title="{.}" href="#"><xsl:number count="*[local-name() = 'note']" level="any"/></a></sup>
    </xsl:template>
    
    <xsl:template match="*[local-name() = 'pb']">
        <div id="{@n}"><xsl:value-of select="@n"/></div>
    </xsl:template>
    
</xsl:stylesheet>
