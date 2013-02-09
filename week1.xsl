<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    version="1.0">
    <xsl:output method="html"></xsl:output>
    

    <xsl:template match="bill">
        <html>
            <head>
                <link href="housexml.css" rel="stylesheet" type="text/css"/>

                <!-- I'm noticing that not everything is Dublin Core-ified, so let's try a when here
                NOTE: To be extended as we discover more title formats!
                -->
                <xsl:choose>
                    <xsl:when test="//dc:title">
                        <title>
                            Transforming Congress: <xsl:value-of select="//dc:title"/>
                        </title>
                    </xsl:when>
                    <xsl:otherwise>
                        <title>Transforming Congress: <xsl:value-of select="//short-title[1]"></xsl:value-of></title>
                    </xsl:otherwise>
                </xsl:choose>
                
                
                
                <!-- Routine click to show/click to hide javascript -->
                <script type="text/javascript">
                    function toggleVis(id){
                    var current = document.getElementById(id);
                    if(current.style.display == 'block')
                        current.style.display = 'none';
                    else
                        current.style.display = 'block';
                    }                 
                </script>
            </head>
            <body>
                <div class="billTitle"><xsl:value-of select="//official-title"/></div>
                <xsl:apply-templates/>        
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="toc[@container-level='legis-body-container']">
        <a class="toggle" onclick="toggleVis('toc')" href="#">Show/Hide Table of Contents</a>
        <div class="toc" id="toc" style="display:block;">Table of Contents:<br />
            <xsl:apply-templates></xsl:apply-templates>
        </div>        
    </xsl:template>


    <!-- Thanks, http://dh.obdurodon.org/avt.html -->
    <xsl:template match="toc-entry[ancestor::node()[@container-level='legis-body-container']]">
        <br />
            <xsl:choose>
                <xsl:when test="@level='title'">
                    <a href="#{@idref}">                     
                    <xsl:apply-templates></xsl:apply-templates>
                    </a>
                </xsl:when>
                <xsl:when test="@level='section'">&#xa0;&#xa0;&#xa0;&#xa0;&#xa0;
                    <a href="#{@idref}">                        
                    <xsl:apply-templates></xsl:apply-templates>
                    </a>
                </xsl:when>
             </xsl:choose>
            <!-- Thanks, semantically-marked sections! -->
        
    </xsl:template>

    <xsl:template match="//section">
        <div class="section"><a name="{@id}"></a>
            <xsl:apply-templates></xsl:apply-templates>
        </div>
    </xsl:template>

    <xsl:template match="//form"></xsl:template>
    <xsl:template match="//dublinCore"></xsl:template>




</xsl:stylesheet>