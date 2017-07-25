<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<xsl:template match="/">
  <html>
    <xsl:apply-templates/>
  </html>
</xsl:template>

<xsl:template match="config_definition">
  <head>
    <title>Configuration Definition</title>
  </head>
  <body>
    <h2>Configuration Definition</h2>

    <table border="1" cellpadding="10">
    <caption><font size="larger"><bold>Physics Configurations</bold></font></caption>
    <tr>
      <th>Name</th>
      <th>Value</th>
      <th>Valid Values</th>
      <th>Description</th>
    </tr>
      <xsl:apply-templates select="entry[@category='physics']"/>
    </table>

    <table border="1" cellpadding="10">
    <caption><font size="larger"><bold>Biogeochemistry Configurations</bold></font></caption>
    <tr>
      <th>Name</th>
      <th>Value</th>
      <th>Valid Value</th>
      <th>Description</th>
    </tr>
      <xsl:apply-templates select="entry[@category='bgc']"/>
    </table>

    <table border="1" cellpadding="10">
    <caption><font size="larger"><bold>Configuration Directories</bold></font></caption>
    <tr>
      <th>Name</th>
      <th>Value</th>
      <th>Valid Value</th>
      <th>Description</th>
    </tr>
      <xsl:apply-templates select="entry[@category='directories']"/>
    </table>

    <table border="1" cellpadding="10">
    <caption><font size="larger"><bold>Configuration Machine Options</bold></font></caption>
    <tr>
      <th>Name</th>
      <th>Value</th>
      <th>Valid Value</th>
      <th>Description</th>
    </tr>
      <xsl:apply-templates select="entry[@category='mach_options']"/>
    </table>

    <table border="1" cellpadding="10">
    <caption><font size="larger">
<bold>Configuration Standalone CLM Testing Options (NOT used by normal CESM scripts)</bold></font></caption>
    <tr>
      <th>Name</th>
      <th>Value</th>
      <th>Valid Value</th>
      <th>Description</th>
    </tr>
      <xsl:apply-templates select="entry[@category='standalone_test']"/>
    </table>

  </body>
</xsl:template>

<xsl:template match="entry">
  <tr>
    <td><font color="#ff0000"><xsl:value-of select="@id"/></font></td>
    <td><xsl:value-of select="@value"/></td>
    <td><xsl:value-of select="@valid_values"/></td>
    <td><xsl:apply-templates/></td>
  </tr>
</xsl:template>


</xsl:stylesheet>
