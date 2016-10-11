<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:template match="@* | node()">
     <xsl:copy>
        <xsl:apply-templates select="@* | node()"/>
     </xsl:copy>
  </xsl:template>

  <xsl:template match="//*[local-name()='config']/*[local-name()='logo']/text()">
    <xsl:value-of select="." disable-output-escaping="yes"/>
  </xsl:template>

  <xsl:template match="//*[local-name()='config']/*[local-name()='footer']/text()">
    <xsl:value-of select="." disable-output-escaping="yes"/>
  </xsl:template>

  <xsl:template match="//*[local-name()='config']/*[local-name()='localReplications']/*[local-name()='localReplication']/*[local-name()='enabled']/text()">
    <xsl:value-of select="." disable-output-escaping="yes"/>
  </xsl:template>

  <xsl:template match="//*[local-name()='config']/*[local-name()='localReplications']/*[local-name()='localReplication']/*[local-name()='url']/text()">
    <xsl:value-of select="." disable-output-escaping="yes"/>
  </xsl:template>

</xsl:stylesheet>
