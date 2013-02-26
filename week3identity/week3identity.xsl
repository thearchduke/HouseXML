<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"> 
    
    <xsl:output method="xml"></xsl:output>
    


<!-- =============================================================
        An XSL spreadsheet for reducing an xml.house.gov bill    +
        to just the legislative language & associated elements.  +
        Possible uses include linguistic analysis.               +
        Or inserting it into another document, maybe             +
        a document that contains the body of multiple bills.     +
        For instance, using document() calls to crawl            +
        and extract the legislative body of linked bills.        +
==================================================================
-->


<!-- No attributes! Intentional! -->
    <xsl:template match="node(  )">
        <xsl:copy>
            <xsl:apply-templates select="node(  )"/>
        </xsl:copy>
    </xsl:template>


    <xsl:template match="dublinCore|enum|form|toc|attestation|metadata|pre-form|endorsement|internal-xref|external-xref|comment()|processing-instruction()"></xsl:template>


    

</xsl:stylesheet>