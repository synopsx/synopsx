<?xml version="1.0" encoding="iso-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"

    xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei"
 xmlns:dc="http://purl.org/dc/terms/" >

    <xsl:output indent="yes" method="xml" encoding="UTF-8" />

    
    <xsl:template match="/">
    <dc:dc>
        <dc:title>
            <xsl:for-each select="//tei:fileDesc/tei:titleStmt/tei:title " >
                 <xsl:value-of select="."/>
            </xsl:for-each>
        </dc:title>
   
       
            <xsl:for-each select="//tei:fileDesc/tei:titleStmt/tei:author">
                <dc:creator>
                <xsl:value-of select="@key"/>
        </dc:creator>
            </xsl:for-each>
            
            
        <xsl:for-each select="//tei:fileDesc/tei:titleStmt/tei:editor">
                <dc:contributor>
                    <xsl:choose>
                        <xsl:when test="@key">
                            <xsl:value-of select="@key"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </dc:contributor>
            </xsl:for-each>
        
        
        <dc:publisher>
            <xsl:apply-templates select="//tei:fileDesc/tei:publicationStmt/tei:publisher" />
        </dc:publisher>
        
        <xsl:if test="//tei:fileDesc/tei:publicationStmt/tei:date">
        <dc:issue>
            <xsl:for-each select="//tei:fileDesc/tei:publicationStmt/tei:date">
                <xsl:value-of select="@when"/>
            </xsl:for-each>
        </dc:issue>
        </xsl:if>
        
        <xsl:if test="//tei:fileDesc/tei:publicationStmt/tei:idno">
            <dc:identifier>
                <xsl:for-each select="//tei:fileDesc/tei:publicationStmt/tei:idno">
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </dc:identifier>
        </xsl:if>
        
        <dc:rights>
            <xsl:for-each select="//tei:fileDesc/tei:publicationStmt/tei:availability/tei:licence">
                <xsl:choose>
                    <xsl:when test="@target">
                        <xsl:value-of select="@target"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </dc:rights>
        
        <xsl:if test="//tei:fileDesc/tei:notesStmt/tei:note">
        <dc:description>
            <xsl:apply-templates select="//tei:fileDesc/tei:notesStmt/tei:note" />
        </dc:description>
        </xsl:if>
        
        <xsl:if test="//tei:fileDesc/tei:sourceDesc/tei:bibl">
            <dc:source>
                <xsl:for-each select="//tei:fileDesc/tei:sourceDesc/tei:bibl" >
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </dc:source>
        </xsl:if>
  
        <dc:date>
            <xsl:for-each select="//tei:profileDesc/tei:creation/tei:date">
                <xsl:choose>
                    <xsl:when test="@when">
                        <xsl:value-of select="@when"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@cert"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </dc:date>
        
        <xsl:if test="//tei:profileDesc/tei:langUsage/tei:language">
            <dc:language>
                <xsl:for-each select="//tei:profileDesc/tei:langUsage/tei:language">
                    <xsl:value-of select="@ident"/>
                </xsl:for-each>
            </dc:language>
        </xsl:if>
  
        <xsl:if test="//tei:profileDesc/tei:textClass/tei:keywords/tei:term/text()">
             <xsl:for-each select="//tei:profileDesc/tei:textClass/tei:keywords/tei:term/text()">
                    <dc:subject>
                        <xsl:value-of select="."/>
                    </dc:subject>
                 </xsl:for-each>
        </xsl:if>
       
    </dc:dc>
    </xsl:template>
    
</xsl:stylesheet>
        
     