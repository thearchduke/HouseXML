<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    
    <!-- This stylesheet traverses the input tree and writing out
element names as it goes, indenting to show the hierarchy. -->
    
    <!-- We want plain text output. -->
    <xsl:output method="text"/>
    
    <!-- Starting from the root with its element child
       (the document element) as $children, we proceed
       through the tree grabbing elements grouped by
       name. First we indent and write the name, then
       we take all the element children of the group
       and do the same thing with them (i.e., group
       their own children by name in turn, etc.) -->
    <xsl:template match="/" name="do-group">
        <xsl:param name="children" select="*"/>
        <xsl:for-each-group select="*" group-by="name()">
            <xsl:call-template name="indent"/>
            <xsl:value-of select="current-grouping-key()"/>
            <xsl:call-template name="do-group">
                <xsl:with-param name="children" select="current-group()/*"/>
            </xsl:call-template>    
        </xsl:for-each-group>
    </xsl:template>
    
    <!-- We indent by emitting a line feed, then spacing for
       every element ancestor the current node has
       (reflecting its depth). -->
    <xsl:template name="indent">
        <xsl:text>&#xA;</xsl:text>
        <xsl:apply-templates select="ancestor::*" mode="spacer"/>
    </xsl:template>
    
    <!-- When indenting, each element indents us two spaces -->
    <xsl:template match="*" mode="spacer">
        <xsl:text>  </xsl:text>
    </xsl:template>
    
</xsl:stylesheet>