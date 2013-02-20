<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    exclude-result-prefixes="dc"
    xmlns="http://www.w3.org/1999/xhtml" 
    version="2.0">
    <xsl:output method="xml"
        doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
        doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
            ></xsl:output>
    
    <!-- COMPLEX TRANSFORMATION SECTION
        ===========================================
        
        
        <external-xref legal-doc="usc" parsable-cite="usc/42/254b">42 U.S.C. 254b et seq.</external-xref>
    becomes:
        http://uscode.house.gov/quicksearch/get.plx?title=42&section=254b

    got document() down; still need to know how to transform 'parsable-cite' (using tokenize(), most likely) into 
    a URI pointing at the appropriate loc.gov URI.


    TO-DO: Get a source doc. of all reps by party, district DONE
    -->

    <!-- See week2xhtmlBadBranch.xsl for some silly tests I was applying to all the template matches 
        because I hadn't realized that the problem was *just* that p cannot contain div, and turning the 
        bodyPara element into a div fixed (almost) everything. Doh. -->

    <!-- Current version: 0.2 (Week 2)
        Author: J. Tynan Burke
        XSL stylesheet to transform & make more useful bills from xml.house.gov
        Some rights reserved, under the CC Attribution-ShareAlike 3.0 Unported License.
            (Basically, drop me a note & credit if for whatever reason you use this)
            
        TO-DO:
            ::Make left column for metadata like votes, and possibly that map I discussed, sponsors, bill status, etc.
            
            
        QUESTIONS:
            ::XHTML transformation seems to take considerably longer. Is this due to accessing the DTD online?
                PROPOSED EXPERIMENT: Put the DTD on your local system and run it, that'll answer your question.
                If it's not DTD access, then the question stands: why? And how can I make it faster?
                FURTHER QUESTION: If it is indeed a matter of simply putting the DTD on the local system, what does that 
                mean for a DTD that may be in flux? Is it best to do a snapshot-in-time processing method, 
                since what the users will be after is really the information, and any change in its 
                official structure is unlikely to be particularly impactful, and much more likely to break things than help things?
                OTHER RANDOM NOTE: This became ten times faster, seemingly at random, after I wrote the preceding note.
                Perhaps this computer knows what's good for it.

            ::<enum> is not transforming properly inside of blockquotes. What gives?
    -->
    
    <xsl:template match="bill">
        <html>
            <head>
                <link href="housexmlComplex.css" rel="stylesheet" type="text/css"/>

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
                <div class="container">
                <div class="billTitle"><xsl:value-of select="/bill/form/legis-num"/>: <xsl:value-of select="/bill/form/legis-type"/><br /><xsl:value-of select="/bill/form/official-title"/></div>
                <xsl:apply-templates/>
                </div>
                <div class="sidebar">
                    <p class="sidePara">SPONSOR(S):<br/>
                    <xsl:for-each select="/bill/form/action/action-desc/sponsor">
                        <xsl:apply-templates></xsl:apply-templates>&#xa0;&#xa0;
                        <xsl:variable name="congId" select="@name-id"></xsl:variable>
                        <a href="http://bioguide.congress.gov/scripts/biodisplay.pl?index={$congId}">(bio)</a>
                    <br/>
                    </xsl:for-each>
                    </p>
                    <p class="sidePara">COSPONSOR(S):<br/>
                    <xsl:for-each select="/bill/form/action/action-desc/cosponsor">
                        <xsl:variable name="congId" select="@name-id"></xsl:variable>
                        <xsl:variable select="document('congBios.xml')/congress/members/rep[id[text()=$congId]]" name="rep"></xsl:variable>
                        <xsl:apply-templates></xsl:apply-templates>,&#xa0;<xsl:value-of select="$rep/party"></xsl:value-of>-<xsl:value-of select="$rep/state"></xsl:value-of>&#xa0;
                        <a href="http://bioguide.congress.gov/scripts/biodisplay.pl?index={$congId}">(bio)</a>
                        <br/>
                    </xsl:for-each>
                    </p>
                </div>
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
        <div class="bodyPara"><a name="{@id}"></a>
            <xsl:apply-templates></xsl:apply-templates>
        </div>
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
        <div class="subsection"><a name="{@id}"></a><br/>
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


<!-- ================================================
        BEGIN COMPLEXITY
        (see 'main' template section for fancy name sidebar)
     ====================================================================
     -->

<!-- Names -->

    
    <!-- Experimental section 


This outputs unmatched elements in red, wrapped around 
their contents:
<xsl:template match="*">
        <span style="color:red">
            <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>&gt;</xsl:text>
  </span>
        <xsl:apply-templates/>
        <span style="color:red">
            <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>&gt;</xsl:text>
  </span>
    </xsl:template>
    

Whereas this sends a (to my mind much more useful, at least 
during development) error message to the transformation 
software:

<xsl:template match="*">
        <xsl:message>
            <xsl:text>Warning: </xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text> was matched by default</xsl:text>
        </xsl:message>
        <xsl:apply-templates/>
    </xsl:template>
    -->


</xsl:stylesheet>