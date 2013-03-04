<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">

<xsl:output method="xml"></xsl:output>

    <!-- identity template -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


<!-- Wendell sez: Use keys here! -->

<!-- 1: Identify the roll call vote -->
    <xsl:variable name="whichVote" select="document('votes.xml')/votes/vote[contains(@bill,'h111-2454') and contains(@title, 'On Passage:')]"></xsl:variable>

<!-- 2: Obtain the information on said vote by number (URL looks like clerk.house.gov/evs/2009/roll971.xml) -->

    <xsl:variable name="rollCallURL" select="string(concat('http://clerk.house.gov/evs/2009/roll', $whichVote/@roll, '.xml'))"></xsl:variable>
    <xsl:variable name="rollCallVote" select="document($rollCallURL)/rollcall-vote/vote-data"></xsl:variable>
    
<!-- 3: Load the variable that we'll use to map id to district -->
    
    <xsl:variable name="congBios" select="document('congBios.xml')/congress/members"></xsl:variable>

    <xsl:template match="@style">
        <xsl:variable name="district" select="parent::node()/@id"></xsl:variable>
    <!-- If this is actually the right select I'll eat my hat: -->
        <xsl:variable name="congId" select="$congBios/rep/id[parent::node()/encodedDistrict=$district]/text()"></xsl:variable>
    <!-- I'll be damned. -->

        <xsl:choose>
        <xsl:when test="$rollCallVote/recorded-vote/legislator[@name-id=$congId]/parent::node()/vote/text()='No'">
            <xsl:attribute name="style">fill: #000;
                <xsl:apply-templates></xsl:apply-templates>
            </xsl:attribute>         
        </xsl:when>
        
        <xsl:when test="$rollCallVote/recorded-vote/legislator[@name-id=$congId]/parent::node()/vote/text()='Aye'">
            <xsl:attribute name="style">fill: #eee;
                <xsl:apply-templates></xsl:apply-templates>
            </xsl:attribute>         
        </xsl:when>
        
        <xsl:otherwise>
            <xsl:attribute name="style">fill: #a00;
                <xsl:apply-templates></xsl:apply-templates>
            </xsl:attribute>
        </xsl:otherwise>
        </xsl:choose>




        <!-- =============================================
            LEFTOVER SCRIBBLING
            
        <xsl:attribute name="style">fill: #abc;<xsl:value-of select="$rollCallVote/recorded-vote/legislator[@name-id=$congId]/parent::node()/vote/text()"></xsl:value-of>
            <xsl:apply-templates></xsl:apply-templates>
        </xsl:attribute>         
-->
            <!--
        <xsl:if test="$rollCallVote/recorded-vote/legislator[@name-id=$congId]/vote[self::text()='Aye']">
            <xsl:attribute name="style">fill: #abc;<xsl:value-of select="$congId"></xsl:value-of>
                <xsl:apply-templates></xsl:apply-templates>
            </xsl:attribute>         
        </xsl:if>
-->
</xsl:template>



</xsl:stylesheet>