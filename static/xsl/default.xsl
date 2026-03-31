<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1">
  <xsl:template match="/">
    <xsl:text>test </xsl:text><apply-templates/>
  </xsl:template>

  <xsl:template match="p">
    <p><apply-templates/></p>
  </xsl:template>
</xsl:stylesheet>