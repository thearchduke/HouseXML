<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    version="1.0">
    <xsl:output method="html"></xsl:output>
    

<!-- Current version: 0.1 (Week 1)
        Author: J. Tynan Burke
        XSL stylesheet to transform & make more useful bills from xml.house.gov
        Some rights reserved, under the CC Attribution-ShareAlike 3.0 Unported License.
            (Basically, drop me a note & credit if for whatever reason you use this)
            
        TO-DO:
            ::Make left column for metadata like votes, and possibly that map I discussed, sponsors, bill status, etc.
-->

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
    
    <!-- Make a hideable TOC, but only the main 'head' TOC -->
    <xsl:template match="toc[@container-level='legis-body-container']">
        <br/><a class="toggle" onclick="toggleVis('toc')" href="#">Show/Hide Table of Contents</a>
        <br/><div class="toc" id="toc" style="display:block;"><span style="font-size: 18px; font-weight: bold;">Table of Contents:</span><br />
            <xsl:apply-templates></xsl:apply-templates>
        </div>        
    </xsl:template>


    <!-- Thanks, http://dh.obdurodon.org/avt.html 
         Makes appropriately-indented TOC entries. Question: What if the @container-level and 
         @level conventions aren't followed?
    -->
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
    
<!-- The preceding is very important for me to understand how it works. I think I'm getting it.
    Thanks, professor! -->


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
    

    <!-- Don't print metadata except as specified above -->
    <xsl:template match="form"></xsl:template>
    <xsl:template match="dublinCore"></xsl:template>




</xsl:stylesheet>