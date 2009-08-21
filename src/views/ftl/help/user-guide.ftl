<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title> User Guide </title>
<link rel="stylesheet" href="<@s.url value="/css/main.css" />" type="text/css">
<style>
h1 { font-size: 18px; text-decoration: none }
h2 { font-size: 16px; text-decoration: underline; text-align: left }
h3 { font-size: 14px; text-decoration: underline; text-align: left }
h4 { font-size: 13px; text-decoration: underline; text-align: left }
ul li { margin-bottom: 5px; }
li em { font-weight: bold; font-style: normal; }
* pre { background-color:#ddeeff; border : 1px solid #0088ff; width: 600px; margin: 5px 0px 5px 30px; padding: 10px; font-family: monospace; font-size: 12px; }
.nrcode { font-family: monospace; font-size: 12px; font-style: italic;}
li pre { margin-left : -9px; }
</style>
</head>

<body>
<div class="ie_center_hack">
<div class="main">

<h1>User guide</h1>
<h2 class="center">(Work in Progress)</h2>

<p> The user guide is still being written.  It will continue
to be updated and made more readable.  Please feel free to
<a href="<@s.url namespace="/about" action="contact" />"> email me your questions </a>.
</p>

<ol>
<li><a href="#intro">Introduction</a></li>
<li><a href="#examples">Examples</a></li>
<li><a href="#profile">Issue / Topic</a></li>
<li><a href="#source">News Source</a></li>
<li><a href="#concept">Concept</a></li>
<li><a href="#category">Filtering Rules / Categories </a></li>
<li><a href="#tips">Tips and Common mistakes</a></li>
</ol>

<hr noshade="noshade">
<a name="intro"></a>
<h2>1. Introduction </h2>
<p>
The process of news monitoring is a multi-step process:
</p>
<ul>
<li> 
<em>Knowing what topic to monitor (and in some case, specifically what aspects of the topic to monitor):</em>
For example, if you want to monitor water-related news, what specific aspects of water exactly?
water as rivers, water privatisation, water supply, drinking water, water pollution, water harvesting,
water-borne diseases, dams, ...  In some cases, the topic you want to monitor is perhaps very
specific enough that you don't have to think of further divisions, for example news about the
Comprehensive Development Plan for Bangalore.  This is the critical first step.  Once you have a
sense of what aspects of a topic you want to monitor, NewsRack lets you organize those aspects
within a taxonomy. 
</li>
<li>
<em>Writing filtering rules to track news for the various aspects you are interested in:</em>
For example if you want to monitor news about organic agriculture, you could write the rule
<pre> [Organic Agriculture] = organic AND (agriculture OR food) </pre>
Rather than use simple keywords in these rules, NewsRack goes one step further and lets you
organize related keywords into concepts and use those concepts to write filtering rules.
For example, for the above rule, you could define concepts as follows: <br />
<pre>
&lt;organic&gt; = organic, organically grown, organically produced
&lt;agriculture&gt; = agriculture, farming, farm, cultivation
&lt;food&gt; = food, grains, fruits, vegetables, veggies
</pre>
Thus, you get greater precision in defining what you are looking for. 
</li>
<li>
<em>Knowing what news sources to track</em>
NewsRack gives you the flexibility of specifying the exact set of news sources you want to
monitor.  So, you can only monitor news from The Hindu, or you could only monitor
all Indian editorial feeds, or you might want to monitor only business related feeds.
But, if you want to monitor "all" news sources, NewsRack also provides features where
you can simply pick "all known feeds", and use those.
</li>
</ul>

<p>
This, in essence, is what is involved in setting up a profile to monitor all the topics
that you are interested in.  We now look at some example profiles and then go into
more details later on.
</p>

<hr noshade="noshade">
<a name="examples"></a>
<h2>2. Example</h2>

<p>
Let us say I am only interested in monitoring news about narmada dams.  I am not interested
in any classification, but, for starters, I want to gather all news items that
pertain to the narmada issue.  In addition, let us also assume that I am only
interested in tracking Rediff and the Hindu front page.  The profile below enables this.
</p>

<h3> Example 1 </h3>
In this example, we will only monitor news about the narmada issue.  For starters,
let us say we only look for the narmada keyword.  In that case, you can use this simple 
format as follows:
<pre>
define sources {my sources}
   http://www.rediff.com/rss/newsrss.xml
   http://www.hindu.com/rss/01hdline.xml
end

define topic Narmada = filter {my sources} with "narmada"
</pre>

As simple as that was, it is limited because the single keyword "narmada" does not capture
all the different dams (sardar sarovar, maheshwar, omkareshwar, etc.).  So, let us refine
that further by organizing keywords into concepts.

<h3> Example 2 </h3>
<pre>
define sources {my sources}
   http://www.rediff.com/rss/newsrss.xml
   http://www.hindu.com/rss/01hdline.xml
end

define concepts
   &lt;narmada-dams&gt; = narmada, sardar sarovar, maheshwar, omkareshwar 
end

define topic Narmada = filter {my sources} with narmada-dams
</pre>

<p>
Note how instead of <i>"narmada"</i> (with quotes) in the topic definition we are now 
using <i>narmada-dams</i> (without quotes).  Non-quoted words refer to concepts you might
have defined earlier.  So, in this case, newsrack will look for all keywords defined
in the narmada-dams concept ("narmada", "sardar sarovar", "maheshwar", "omkareshwar").
</p>

Also note that the concept is defined as:
<pre>
   &lt;narmada-dams&gt; = narmada, sardar sarovar, maheshwar, omkareshwar 
</pre>
<p>
The word on the left in angle-brackets is the name of the concept.  The list of keywords 
on the right are separated by commas.  Quotes are not necessary, but you could use them
if you want to.
</p>
<p>
We can refine our filtering rule further by checking for occurence of dams in the text as
in the next example.
</p>

<h3> Example 3 </h3>
<pre>
define sources {my sources}
   http://www.rediff.com/rss/newsrss.xml
   http://www.hindu.com/rss/01hdline.xml
end

define concepts
   &lt;narmada-dams&gt; = narmada, sardar sarovar, maheshwar, omkareshwar 
   &lt;dams&gt; = dam, reservoir
end

define topic Narmada = filter {my sources} with narmada-dams AND dams
</pre>
The rule <i>narmada-dams AND dams</i> check for presence of both the narmada-dams
and the dams concepts within the text.  This ensures that references to the narmada river
without any mention of dams won't get picked up.  Filtering rules are basically boolean
expressions on concepts.  So, you could have a rule as <i> (narmada-dams OR other-dams) AND dams </i>.

But, if you want to track news from different dams in different categories, you can also
do that by defining a taxonomy as in the next example below

<h3> Example 4 </h3>
<pre>
define sources {my sources}
   http://www.rediff.com/rss/newsrss.xml
   http://www.hindu.com/rss/01hdline.xml
end

define concepts
   &lt;ssp&gt; = sardar sarovar, ssp
   &lt;maheshwar&gt; = maheshwar
   &lt;indira-sagar&gt; = indira-sagar
   &lt;omkareshwar&gt; = omkareshwar
   &lt;any-narmada-dam&gt; = &lt;ssp&gt;, &lt;maheshwar&gt;, &lt;indira-sagar&gt;, &lt;omkareshwar&gt;
   &lt;dams&gt; = dam, reservoir
end

define issue Dams = filter {my sources} into taxonomy
   [Sardar Sarovar] = ssp AND dams
   [Indira Sagar] = indira-sagar AND dams
   [Maheshwar] = maheshwar AND dams
   [Omkareshwar] = omkareshwar AND dams
   [Any Narmada Dam 1] = (ssp OR indira-sagar OR maheshwar OR omkareshwar) AND dams
   [Any Narmada Dam 2] = any-narmada-dam AND dams
end
</pre>
<p>
Thus, you can monitor multiple related topics at the same time and organize them. 
The <i>any-narmada-dam</i> concept shows you how you can define new concepts by
building on existing ones.  The categories <i>Any Narmada Dam 1</i> and
<i>Any Narmada Dam 2</i> will be identical in terms of the news they collect.
This example shows two ways of doing the same thing.
</p>
<p>It is easy to see how this can be extended.  If you want to add more
categories to the "Dams issue", you can do so by adding more category
definitions.  Accordingly, you might have to define more concepts in the earlier
"define concepts" element.  You could also add additional news sources, say, 
BBC South Asia's RSS feed by adding a entry in the "define sources" element.
</p>
<p>
You are not restricted to define only one issue either.  You can define as many
issues as you want, as long as you specify what news sources to monitor, how
you want to organize your news, and specify the filtering rules as above.
</p>
<hr noshade="noshade">
<a name="source"></a>
<h2>3. Issue / Topic </h2>

<p>
An issue is nothing but a collection of categories within which you organize
news for your topic of interest.  For example, for a topic about dams, there
could be one category each for different dams: Almatti, Sardar Sarovar,
Omkareshwar, Tehri, Tipaimukh, KRS, Mullaperiyar, and so on.
</p>
<p>
An issue is defined as follows:
<pre>
define issue ISSUE-NAME-HERE = filter {SOURCES-HERE} into taxonomy 
   TAXONOMY-HERE
end
</pre>
Further down, you will see how news sources are defined, and how taxonomies are defined.
</p>

<hr noshade="noshade">
<a name="source"></a>
<h2>4. News Source</h2>

<p>
Most of the time, you will not have to define news sources yourself because there will
already exist a collection of various news feeds that have accumulated over time.
You can then simply use an existing news collection from another user.  So, let us say
user subbu has defined the following feed collections: {All Feeds} and {Sports Feeds}.
Then you can use them as follows:
<pre>
import {All Feeds} from subbu
import {Sports Feeds} from subbu

... define concepts here ...

define issue My Topic = filter sources {All Feeds}, -{Sports Feeds}, into taxonomy
   TAXONOMY-HERE
end
</pre>

Thus, for your issues, you can take the {All Feeds} collection that user
subbu has defined and ignore feeds defined in the {Sports Feeds} collection.
This is an example of how you can pick the news feeds that you want to monitor.
</p>

<p>
But, for those occasions when you want to define your own feeds, or pick feeds
yourself, you can do that as follows:
<pre>
define sources {Hindu Feeds}
  http://www.hindu.com/rss/01hdline.xml
  http://www.hindu.com/rss/02hdline.xml
  ...
  ...
  http://www.hindu.com/rss/07hdline.xml
end

define sources {TOI Feeds}
  ... rss feed urls here ...
end

define sources {Hindustan Times Feeds}
  ... rss feed urls here ...
end

define sources {Indian RSS Feeds}
  {Hindu Feeds}, {TOI Feeds}, {Hindustan Times Feeds}, ...
end
</pre>
</p>

<hr noshade="noshade">
<a name="concept"></a>
<h2>5. Concept</h2>

<p>
A concept is specified using the following format:
<pre>
&lt;hydel&gt; = hydel, hydro, hydro-electric, hydro-electricity
&lt;bmic&gt; = bmic, bmicapa, bmicpa, bangalore mysore infrastructure corridor
</pre>
</p>
<p>
A natural question is: why concepts?  Concepts make sense for several reasons as below.
<ul>
<li> 
<span class="underline">They capture ideas in a way that keywords do not</span>.
For example, consider the following three concepts:
<pre>
1. &lt;oil-exploration&gt; = oil exploration, offshore oil, oil-field, oil hunt,
                       oil find, oil rig, oil production
2. &lt;narmada&gt; = narmada, sardar sarovar, maheshwar, omkareshwar 
3. &lt;athirapally&gt; = athirapally, athirapilly, athirapilli, athirappilli
</pre>
The first concept captures the idea of oil exploration and not just one particular keyword.
The second concept captures the names of different narmada dams.  The third concept captures
different spelling variations of a name.  Thus, the idea of concepts is more versatile.
</li>

<li>
<span class="underline">They simplify filtering rules</span>.  Compare <span class="nrcode">oil-exploration OR (oil AND drilling)</span> with
<span class="nrcode">oil exploration OR offshore (oil OR oil-field OR ...) AND ((oil OR ...) AND (drilling OR ..))</span>
</li>

<li>
<span class="underline">Multilingualism comes naturally</span>.
Consider the concept: <span class="nrcode"> &lt;oil&gt; = oil, तेल, ಎಣ್ಣೆ </span>  This concept will find all articles in English, Hindi,
and Kannada that mention oil.  Thus, you can capture articles about a topic across languages in the same category.
</li>

<li>
<span class="underline">Maintenance is easy</span>.
If tomorrow you wanted to monitor news in Telugu, all you need to do is go and
add the Telugu keyword for oil in the concept definition of oil, and everything works fine!
</li>
</ul>
</p>
<h3>Notes about matching in concepts</h3>
<ul>
<li>
NewsRack automatically attempts to pluralize keywords in a somewhat
crude way.  For words ending in "y", it checks for its plural ending
in "ies"; for words ending in "s", it check for its plural ending
in "es"; and for everything else, checks for plural ending in "s".
So, for example, if a concept specifies "train", "trains" is also
matched; for "city", "cities" is also matched, and for "bus", "buses"
is also matched.  Till a generic stemmer is used, NewsRack will not
be smarter than this (at this stage).  In future designs, attempts
will be made to implement different language-specific stemmers -- NOTE
that the above implicit pluralizing rules are English-specific and
will not work for other languages.
</li>
<li>
The character <b>-</b> has a special meaning within keywords.  It will match
white space, the "-" character, or nothing at all.  So, for example, the 
following keyword: "hydro-electric" will match "hydroelectric", "hydro-electric",
and "hydro electric".  So, the "-" character can be used to match keywords
that are written in different forms like this.
</li>
</ul>

<hr noshade="noshade">
<a name="category"></a>
<h2>6. Filtering Rules / Categories </h2>

<p>
As discussed earlier, NewsRack makes it possible for news articles within a topic to
be organized into several categories (or sub-topics).  NewsRack requires you to specify
filtering rules so that it knows when to add an article to a category.
</p>
<p>
A news category within a topic is defined using the following format:
<pre>
[Narmada Dams] = narmada AND dams
</pre>
The text between '[' and ']' is the name of the category, and the text on
the right of '=' defines a filtering rule.  This rule dictates when a news
article is added to this category.  A filtering rule is a boolean expression
using concepts.  For example, all the following are valid filtering rules:
<pre>
1. dam
2. dam AND india
3. dam AND -smalldam
4. dam AND (india OR pakistan)
</pre>
At this time, "AND" and "OR" and "-" are supported with their obvious meanings.
<ul>
<li> The first rule triggers whenever a dam concept is seen. </li>
<li> The second rule triggers only when both a dam concept and the india concept is seen. </li>
<li> The third rule triggers only when the dam concept is present, but the smalldam concept is not present.</li>
<li> The fourth rule triggers whenever a dam concept and either india or pakistan concepts are seen.  </li>
</ul>
</p>

<p>
The next sections discuss a couple more advanced filtering options: proximity operator (~n), context-based filtering, specifying minimum # of occurences, nested categories.
</p>

<h3> 6.1 Proximity operator (~n) </h3>

<p>
Sometimes, two words/phrases you want to match might occur in different combinations.  For example, interlinking of rivers can occur in text in the 
following forms: "river linking", "linking rivers", "linking of rivers", "linking of many rivers", "river inter-linking", "interlinking of rivers", and
possibly a few others.  One way to do this is to define a concept that anticipates all these different phrase forms and records them in a single concept
as follows: 
<pre>
define concepts
  &lt;interlinking&gt; = river linking, linking rivers, linking of rivers,
                   river interlinking, interlinking of rivers
end
def topic Interlinking = filter {rss.feeds} with interlinking
</pre>
While this will work, this is both cumbersome and might not necessarily capture everything.  Another way to handle this situation is to use the
proximity operator.  For example, consider the following example:
<pre>
def concepts
  &lt;river&gt; = river
  &lt;interlinking&gt; = interlinking, linking
end
def topic Interlinking = filter {rss.feeds} with (river ~2 interlinking)
</pre>
The filtering rule: <span class="nrcode"> river ~2 interlinking </span> will trigger whenever the concepts river and interlinking are separated
by at most two words.  This is more robust.
</p>
<p> One more example.  Consider the concepts:
<pre>
&lt;president&gt; = president, "mr."
&lt;obama&gt; = obama, obaama
</pre>
With these concepts, the filtering rule <span class="nrcode">(president ~1 obama)</span> tries to match concepts president and obama separated by
at most 1 word.   So, this will match "President Barack Obama" as well as "Mr. Obama" as well as "Mr. Barack Hussein Obaama".
<p>
So, more generally, the filtering rule <span class="nrcode"> a ~N b </span> will look for concepts 'a' and 'b' in text separated by at most N words.
</p>

<h3>6.2 Context qualification</h3>

<p>
Context qualification is also supported in filtering rules.  This is best
explained using an example.  Consider the two rules:
<pre>
1. maheshwar
2. |dam, hydel, narmada|.maheshwar
</pre>
The first rule will match whenever the maheshwar concept is encountered in the article.
But, "maheshwar" could be the name of a person or a place and I might only be interested
in the reference to the Maheshwar dam and not about someone called maheshwar.  In cases
such as these, the second rule might be useful.  It asks newsrack to match the maheshwar
concept only if the article has references to dam, hydroelectricity, or narmada.
</p>

<h3>6.3 Controlling number of matches of a concept </h3>

<p>
NewsRack, by default, considers a concept to have matched if it finds at least two occurences.  
For shorter articles (150 words or less), it loosens this requirement to only one occurence.
But, you also have the option of changing this requirement in filtering rules as follows:
<pre>
dam AND india:1
dam:5 AND india:5
</pre>
In the first case, you are asking that a single match of the india concept is sufficient.
In the second case, you are asking that you want at least 5 matches of the dam and india concepts.
</p>

<h3>6.4 Nested Categories</h3>

<p>
Categories can also be organized into taxonomies.  So, you can define:
<pre>
[Dams] = { 
   [Athirapally] = athirapally AND dam
   ...
   [Sardar Sarovar] = sardar sarovar 
   ...
   [Tipaimukh] = tipaimukh AND dam
   [Tungabhadra] = tungabhadra AND dam
}
</pre>
You can nest categories however much you want.  For example:
<pre>
[Dams] = {
   [By State] = {
      ...
      [Karnataka] = {
         [Linganamakki] = linganamakki AND dam
         ...
         [Tungabhadra] = tungabhadra AND dam
      }
      [Kerala] = {
         [Athirapally] = athirapalli AND dam
         [Mullaperiyar] = mullaperiyar
      }
      ...
   }
   [By Purpose] = {
      [Flood Control] = ...
      [Hydroelectricity] = ...
      [Irrigation] = ...
      ...
   }
}
</pre>
</p>

<hr noshade="noshade">
<a name="tips"></a>
<h2>7. Tips </h2>

<ul>
<li>
Defining topics in a way that you get what you want takes some effort.  But, usually, the effort
is worth the results.  It usually helps to use some news articles as reference while defining
concepts and filtering rules.
</li>

<li>
You can create as many files as necessary.  You can create one file each per topic.  Or, you can
create one file to define rss feeds, another to define concepts, and another to define topics.
You can use the import command to reference collections from other files.  For example,
<pre>
1. import sources {rss.feeds}
2. import concepts {narmada concepts}
3. import concepts {organic concepts} from demo
4. import categories {agriculture categories} from shyam
</pre>
The first 2 commands import the named collections from your own account, no matter what file they
are defined in.  The last 2 commands import the named collections from other users, demo, and shyam
respectively.
</li>

<li>
While defining concepts, the most common mistake made is to end a definition with a trailing ","
as in the first definition below.
<pre>
WRONG! &lt;dams&gt; = narmada, maheshwar, tehri, tipaimukh,
RIGHT! &lt;dams&gt; = narmada, maheshwar, tehri, tipaimukh
</pre>
</li>

<li>
Currently, by default, all definitions within NewsRack are accessible to other users.  Therefore,
you can look at how other users have defined topics using the 'Get From Other Users' feature.
If you click on this link (seen on the Edit Profile page), you will get a list of all files that
other users have defined.  You can view, download, or copy the file, as you wish.  Doing this
gives you a quick start.  You can even simply use the import command to use concepts, categories,
and sources from other users without copying anything.  But, if the other user changes the
definitions, they will get reflected in yours too.  If the other user deletes anything, then
your definitions might cease to be valid after that.
</li>

<li>
It is rarely going to be the case that your rules are defined so precisely that you will get
exactly what you want.  There are going to be some news items that are added to your topics
that you might not be interested in.  In those cases, you have the option of selecting those
and deleting them.  The delete option shows up when you are signed in and browse your topics.
</li>

</ul>

</div>
</div>

<#include "/ftl/layout/footer.ftl" parse="n">
</body>
</html>
