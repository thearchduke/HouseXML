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
                <div class="billTitle"><xsl:value-of select="/bill/form/legis-num"/>: <xsl:value-of select="/bill/form/legis-type"/><br /><xsl:value-of select="/bill/form/official-title"/></div>
                <xsl:apply-templates/>        
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="toc[@container-level='legis-body-container']">
        <br/><a class="toggle" onclick="toggleVis('toc')" href="#">Show/Hide Table of Contents</a>
        <br/><div class="toc" id="toc" style="display:block;"><span style="font-size: 18px; font-weight: bold;">Table of Contents:</span><br />
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

    <xsl:template match="quoted-block">
        <div class="blockquote">
            <xsl:apply-templates></xsl:apply-templates>
        </div>
        <xsl:apply-templates select="after-quoted-block" mode="after"></xsl:apply-templates>
    </xsl:template>
    
<!-- WTF CONGRESS what is this 'after-quoted-block' being inside 'quoted-block' nonsense -->
        
    <xsl:template match="after-quoted-block">
    </xsl:template>

    <xsl:template match="after-quoted-block" mode="after">
        <xsl:if test="not(self::node()[text()='.'])">
            <div class="afterBlockquote">
                <xsl:apply-templates></xsl:apply-templates>
            </div>
        </xsl:if>
    </xsl:template>
    

    <xsl:template match="paragraph">
        <p class="bodyPara"><a name="{@id}"></a>
            <xsl:apply-templates></xsl:apply-templates>
        </p>
    </xsl:template>

    <xsl:template match="enum">
        <xsl:apply-templates></xsl:apply-templates>&#xa0;
    </xsl:template>

    <xsl:template match="section">
        <div class="section"><a name="{@id}"></a>
            <xsl:apply-templates></xsl:apply-templates>
        </div>
    </xsl:template>

    <xsl:template match="subsection">
        <div class="subsection"><a name="{@id}"></a>
            <xsl:apply-templates></xsl:apply-templates>
        </div>
    </xsl:template>

    <xsl:template match="header">
        <span class="header">
            <xsl:apply-templates></xsl:apply-templates><br/>&#xa0;&#xa0;&#xa0;
        </span>
    </xsl:template>
    

    <xsl:template match="form"></xsl:template>
    <xsl:template match="dublinCore"></xsl:template>




</xsl:stylesheet>