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
        
        
        Current version: 0.4
        Author: J. Tynan Burke
        XSL stylesheet to transform & make more useful bills from xml.house.gov
        Some rights reserved, under the CC Attribution-ShareAlike 3.0 Unported License.
            (Basically, drop me a note & credit if for whatever reason you use this)
            
        TO-DO:
            ::Roll call votes (NOTE: If this was easy, somebody would have done it)
                -Possible to use the NY Times congressional API to get these? Running into some snags (mostly different variable standards)...
                -No! Use the govtrack.us API. Sample: http://www.govtrack.us/api/v2/vote/?congress=112&chamber=house&session=2011&format=xml 
                    gets (quite quickly) all the bills from a congress/year intersection as XML. Refining the search is surprisingly difficult.
                -NO! Use this: https://www.opencongress.org/vote/2011/h/257
                -OK, this is turning out to be surprisingly difficult information to get.
                -OK, I'm going to make an executive decision and limit this to the 111th congress. And just get an XML db and query it.
            ::Has it been signed by the president?
            ::For Cocoon application, implementation, let's have it do this to save us some time:
                1. Get the XML document from xml.house.gov
                2. Perform an identity transform that changes the DTD location to a local file so we don't have to download it every. single. time.
                3. Perform the rest of the transformation on THAT.
            ::Seriously, I need to learn SVG

        NEW FEATURES:
            ::Links to Cornell Law Library USC information (NOT COMPLETE, requires a coded @parsable-cite in external-xref; many references don't have this)
            ::Bill status; specifically, did it pass the House, and has it passed both chambers (SEMI-COMPLETE; have hand-coded only two of many 
                possible statuses with a generic fallback position.)
            ::Dublin Core content now incorporated into proper XHTML meta tags. Rather proud of how I do that one.
            
        QUESTIONS:
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
            <!-- To Dublin Core-ify
                <xsl:copy-of select="//dc:*"></xsl:copy-of>
                                                            -->

                <!-- Now to Dublin Core-ify for real, in valid XHTML
                        QUESTION: Why on earth do I need the non-breaking space there for it to output?
                        (If I don't have anything there, I get no meta's; putting anything at all there works though. -->

                <xsl:for-each select="//dublinCore/child::node()">
                    <xsl:if test="text()">
                        <xsl:variable name="whichDC" select="substring-after(name(), 'dc:')"></xsl:variable>
                        <xsl:variable name="dcValue" select="text()"></xsl:variable>
                        <meta name="DC.{$whichDC}" content="{$dcValue}"></meta>&#xa0;
                    </xsl:if>
                </xsl:for-each>

                
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
                    <p class="sidePara">
                    <xsl:choose>
                        <xsl:when test="@bill-stage ='Engrossed-in-House'">
                            BILL STATUS:&#xa0;Passed by the House but not sent to the President
                        </xsl:when>
                        <xsl:when test="@bill-stage ='Enrolled-Bill'">
                            BILL STATUS:&#xa0;Passed in identical form in the House and Senate, sent to the President
                        </xsl:when>
                        <xsl:otherwise>
                            BILL STATUS:&#xa0;Has not passed the House
                        </xsl:otherwise>
                    </xsl:choose>
                    </p>
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
                    <p class="sidePara">VOTE(S):<br/>
                    
                    
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
        (actually it turns out most of the complexity is in the 'main' 
        part of the transformation up top)
     ====================================================================
     -->

    <xsl:template match="external-xref">
        <xsl:variable name="uscUrl" select="substring-after(@parsable-cite, 'usc/')"></xsl:variable>
        <a href="http://www.law.cornell.edu/uscode/text/{$uscUrl}">
            <xsl:apply-templates></xsl:apply-templates>
        </a>
    </xsl:template>

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