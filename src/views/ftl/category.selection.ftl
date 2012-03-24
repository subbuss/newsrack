<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title> NewsRack: Topic Listing</title>
<#include "/ftl/layout/common_includes.ftl">

<style type="text/css">
div.catselection {
	line-height : 150%;
}
div.catselection div {
	margin      : 10px 0px;
}
div.catselection table.selCats {
	width       : 100%;
   margin      : 12px 8px;
	padding     : 4px;
	background  : #f8f8f8;
}

table.selCats td {
	vertical-align: top;
	padding     : 5px 15px 5px 5px;
	font-size   : 14px;
}

<!--
a.selcat {
   text-decoration : none;
	padding         : 0px 5px;
	color           : #0088aa;
}
a.selcat:hover {
	color      : white;
	background : #0088aa;
}
-->
a.selcat { padding: 2px 0px; line-height:150%; text-decoration: none; color: #882222; font-size: 12px; }
a.selcat:hover { padding: 2px 0px; text-decoration: none; background-color: #882222; color: white }
</style>
</head>

<body>

<div class="bodymain">
<table class="userhome" cellspacing="0">
<#include "/ftl/layout/header.ftl"><tr>
<#include "/ftl/layout/left.menu.ftl"><td class="user_space">
<div class="catselection">
<h1>Sample Topics</h1>
<div>
This is a sample editorial selection of all news categories on NewsRack being monitored by several registered users of NewsRack.
<a class="bold" href="<@s.url namespace="/" action="browse" />">Browse the public archives</a>
for a complete listing of classified news across all users.
</div>

<table class="selCats">
<tr> <td class="bold center underline" colspan="3"> Topics with an Indian focus (with mostly Indian news sources) </td> </tr>
<tr>
<td width="33%">
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Bangalore" catID="14" />">&nbsp;ABIDe-Bangalore</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="prs" issue="Legal-News" catID="1" />">&nbsp;Acts &amp; Bills (Central)</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="ifinews" issue="IFIs" catID="7" />">&nbsp;ADB</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="Adivasi" />">&nbsp;Adivasi</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="rahuldewan" issue="Airlines" catID="3" />">&nbsp;Airlines &amp; Airports</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Health" catID="19" />">&nbsp;Alzheimers</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="campaigns" issue="Attacks+on+Women" catID="1" />">&nbsp;Attacks on Women</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="fredericknoronha" issue="Autism" catID="1" />">&nbsp;Autism</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Bangalore" />">&nbsp;Bangalore</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Bangalore" catID="4" />">&nbsp;Bangalore Metrorail</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="gujarat" catID="5" />">&nbsp;Best Bakery</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="bhopal" />">&nbsp;Bhopal</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="campaigns" issue="Binayak+Sen" catID="1" />">&nbsp;Binayak Sen</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="indiatogether" issue="Environment" catID="1" />">&nbsp;Biodiversity</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="Energy" catID="7" />">&nbsp;Biomass</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Issues" catID="15" />">&nbsp;BMIC</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Bangalore" catID="7" />">&nbsp;Bus Rapid Transport (BRT)</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Health" catID="10" />">&nbsp;Cancer</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Decision-Making" catID="6" />">&nbsp;CDP Bangalore</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="indiatogether" issue="Human+Rights" catID="1" />">&nbsp;Child Labour</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="tulir" issue="Child+Sexual+Abuse" />">&nbsp;Child Sexual Abuse</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="Climate+Change" />">&nbsp;Climate Change</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Decision-Making" catID="4" />">&nbsp;CRZ</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="narmada" catID="2" />">&nbsp;Dams</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="narmada" catID="27" />">&nbsp;Dam Breaches</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="narmada" catID="57" />">&nbsp;Dam Siltation</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="lawrenceliang" issue="Slum+Demolition+in+Delhi" />">&nbsp;Delhi Slums</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Health" catID="9" />">&nbsp;Diabetes</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="indiatogether" issue="Health" catID="1" />">&nbsp;Disabilities</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="fredericknoronha" issue="Documentary" catID="1" />">&nbsp;Documentary</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="indiatogether" issue="Human+Rights" catID="3" />">&nbsp;Dowry</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="indiatogether" issue="Government" catID="1" />">&nbsp;E-Governance</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="Energy" />">&nbsp;Energy</a><br />
</td>
<td width="33%">
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Decision-Making" catID="3" />">&nbsp;EIAs</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="indiatogether" issue="NREGA" catID="1" />">&nbsp;Employment Guarantee</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="ESG+in+the+news" catID="1" />">&nbsp;ESG in the news</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="lawrenceliang" issue="Encounter+Killings" catID="4" />">&nbsp;Fake Encounters</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="rohan" issue="Foreign+Direct+Investment+in+Retail" />">&nbsp;FDI in Retail</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="venniyoor" issue="FM+Radio" catID="1" />">&nbsp;FM Radio</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="indiatogether" issue="Agriculture" catID="2" />">&nbsp;GE/GM</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="gujarat" catID="2" />">&nbsp;Godhra</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="campaigns" issue="Green+Hunt" catID="1" />">&nbsp;Green Hunt</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="jai_ism" issue="Harry-Potter" />">&nbsp;Harry Potter</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Hasiru+Usiru" catID="1" />">&nbsp;Hasiru Usiru</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Health" catID="14" />">&nbsp;HIV/AIDs</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="indiatogether" issue="Human+Rights" catID="2" />">&nbsp;Hunger</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="narmada" catID="12" />">&nbsp;Hydel Power</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="wsf" issue="wsf" catID="2" />">&nbsp;India Social Forum</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Health" catID="24" />">&nbsp;Infanticide</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Health" catID="22" />">&nbsp;Infant Mortality</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="leigh" issue="Informal+Sector" />">&nbsp;Informal Sector</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="TahirAmin" issue="IP" />">&nbsp;Intellectual Property</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="narmada" catID="16" />">&nbsp;Interlinking</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="ifinews" issue="IFIs" catID="1" />">&nbsp;JBIC</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="makbak" issue="JNNURM" catID="1" />">&nbsp;JNNURM</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Issues" catID="16" />">&nbsp;Kalinganagar</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Issues" catID="13" />">&nbsp;Kudremukh</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="campaigns" issue="Lokpal+Bill" />">&nbsp;Lokpal Bill</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Health" catID="4" />">&nbsp;Malaria</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="indiatogether" issue="Health" catID="3" />">&nbsp;Mental Health</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Health" catID="23" />">&nbsp;Maternal Mortality</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="indiatogether" issue="Media" catID="4" />">&nbsp;Media Ownership</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="leigh" issue="Micro+Credit" />">&nbsp;Micro Credit</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Issues" catID="17" />">&nbsp;Mining</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="demo" issue="Multilingual-Demo" />">&nbsp;Multi Languages Demo</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="iwphindi" issue="Water" catID="2" />">&nbsp;पानी</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="Land+Issues" catID="4" />">&nbsp;Nandigram</a><br />
</td>
<td>
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="narmada" catID="7" />">&nbsp;Narmada Dams</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="narmada" catID="14" />">&nbsp;Narmada Rehab</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Decision-Making" catID="6" />">&nbsp;National Envt. Policy</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="Energy" catID="5" />">&nbsp;Nuclear Energy</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="nuclear" issue="Nuclear+Issues" />">&nbsp;Nuclear Issues</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Issues" catID="12" />">&nbsp;Oil Exploration</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="organic-agriculture" catID="1" />">&nbsp;Organic Agriculture</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="campaigns" issue="Pink+Chaddi+Campaign" catID="1" />">&nbsp;Pink Chaddi Campaign</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="Companies" catID="3" />">&nbsp;POSCO</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="ammujo" issue="Pratibha-BPO" />">&nbsp;Prathibha-BPO Murder</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Decision-Making" catID="5" />">&nbsp;Public Hearings</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="servelots" issue="Energy" catID="1" />">&nbsp;Renewable Energy</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="caste" issue="Reservation" />">&nbsp;Reservations</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="fredericknoronha" issue="Right+to+Information" catID="1" />">&nbsp;Right to Information</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="leigh" issue="Suicides" />">&nbsp;Rural Suicides</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="indiatogether" issue="Health" catID="5" />">&nbsp;Sanitation</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="Land+Issues" catID="1" />">&nbsp;SEZ</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="lgbt" issue="Sexual+Minorities" />">&nbsp;Sexual Minorities</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="divya_rrs" issue="Shivaji+Statue+in+Bombay" catID="1" />">&nbsp;Shivaji Statue, Mumbai</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="Land+Issues" catID="3" />">&nbsp;Singur</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="Energy" catID="6" />">&nbsp;Solar Energy</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="indiatogether" issue="Education" catID="2" />">&nbsp;Special Education</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="musafir" issue="Surveillance" catID="1" />">&nbsp;Surveillance</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="norgay" issue="Tibet" />">&nbsp;Tibet</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Health" catID="5" />">&nbsp;Tuberculosis</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="fredericknoronha" issue="Urban+Planning" catID="1" />">&nbsp;Urban Planning</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="Iram" issue="Muslim+Women" catID="1" />">&nbsp;Veiling Practices</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Issues" catID="1" />">&nbsp;Waste</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="esg" issue="Health" catID="6" />">&nbsp;Water-borne Diseases</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="narmada" catID="1" />">&nbsp;Water Harvesting</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbutest" issue="water-privatisation" catID="2" />">&nbsp;Water Privatisation</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="arghyam" issue="Water" />">&nbsp;Water</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="subbu" issue="Energy" catID="2" />">&nbsp;Wind Energy</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="ifinews" issue="IFIs" catID="2" />">&nbsp;World Bank</a><br />
</td>
</tr>
<tr> <td class="bold center underline" colspan="3"> Topics with an US focus (with a restricted set of US news sources) </td> </tr>
<tr>
<td>
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="irge304" issue="Biodiversity" />">&nbsp;Biodiversity</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="demo" issue="Climate+Change" />">&nbsp;Climate Change</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="demo" issue="Energy" />">&nbsp;Energy</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="irge304" issue="Energy+Extraction" />">&nbsp;Energy Extraction</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="irge304" issue="Environmental+Justice+Issues" />">&nbsp;Environmental Justice</a><br />
</td>
<td>
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="irge304" issue="Extreme+Weather" />">&nbsp;Extreme Weather</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="demo" issue="Agriculture" catID="2" />">&nbsp;GE Foods</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="newstrust" issue="Green+Technology" />">&nbsp;Green Technology</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="demo" issue="Housing" />">&nbsp;Housing</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="newstrust" issue="Immigration" />">&nbsp;Immigration</a><br />
</td>
<td>
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="demo" issue="Katrina" />">&nbsp;Katrina</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="demo" issue="Agriculture" catID="1" />">&nbsp;Organic Agriculture</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="demo" issue="University+Privatization" catID="2" />">&nbsp;Public Schools</a><br />
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="irge304" issue="Urban+Waste" />">&nbsp;Urban Waste</a><br />
</td>
</tr>
<tr> 
<td class="bold center underline" colspan="3"> 
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="flenvcenter" />">Topics set up by Fort Lewis Environmental Center</a><br />
</td>
</tr>
<tr> <td class="bold center underline" colspan="3"> </td> </tr>
<tr> 
<td class="bold center underline" colspan="3"> 
<a class="selcat" href="<@s.url namespace="/" action="browse" owner="irge304" />">Topics set up for Boston University's IR/GE 304 Course (Fall 2007)</a><br />
</td>
</tr>
</table>

</div>
</td>
</tr>
</table>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
