package newsrack.filter.parser;

import beaver.Symbol;
import beaver.Scanner;
import newsrack.filter.parser.NRLanguageParser.Terminals;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

%%

%pack
%unicode
%public
%caseless
%class NRLanguageScanner
%extends Scanner
%function nextToken
%type Symbol
%line
%column
%yylexthrow Scanner.Exception
%eofval{
	return new Symbol(Terminals.EOF, "end-of-file");
%eofval}

%{
   static private Log _log = LogFactory.getLog(NRLanguageScanner.class);

   StringBuffer string = new StringBuffer();
   public Symbol token(short tok, String s)
	{
		if (_log.isDebugEnabled()) _log.debug("token - " + s + ", " + tok);
		return new Symbol(tok, yyline+1, yycolumn+1, yylength(), s);
	}

   public Symbol token(short tok) 
	{
		return token(tok, yytext());
	}
%}

NUMBER = [:digit:]+(,[:digit]+)*(\.[:digit]+)?
WORD   = ([:letter:]|[:digit:])([:letter:]|[:digit:]|\.|\-|[^ ,;:?+*&\^%$#@!|~/`<>\.\-\t\n\r\\\'\"\-\{\}()\[\]])*
WS     = [ \t\n\r]
SPACE  = {WS}*

%state COMMENT, STRING

%%
<YYINITIAL> {
	"(*"                        { yybegin(COMMENT); }
	\"                          { string.setLength(0); yybegin(STRING); }
	{SPACE}                     { }
	"http://"[^ \t\n\r]*        { return token(Terminals.URL_TOK); }
	"---""-"*                   { /** separator line (3 or more hyphens) ! ignore **/ }
	"~"								 { return token(Terminals.TILDE); }
	"{"							    { return token(Terminals.LBRACE); }
	"}"                         { return token(Terminals.RBRACE); }
	"("							    { return token(Terminals.LPAREN); }
	")"                         { return token(Terminals.RPAREN); }
	"["							    { return token(Terminals.LBRACKET); }
	"]"                         { return token(Terminals.RBRACKET); }
	"<"							    { return token(Terminals.LANGLE); }
	">"                         { return token(Terminals.RANGLE); }
	"-"                         { return token(Terminals.HYPHEN); }
	"="                         { return token(Terminals.EQUAL); }
	":"                         { return token(Terminals.COLON); }
	"."                         { return token(Terminals.DOT); }
	","                         { return token(Terminals.COMMA); }
	"|"                         { return token(Terminals.PIPE); }
	"OR"                        { return token(Terminals.OR); }
	"AND"                       { return token(Terminals.AND); }
   "FROM"                      { return token(Terminals.FROM); }
	"WITH"                      { return token(Terminals.WITH); }
	"INTO"{SPACE}"TAXONOMY"     { return token(Terminals.INTO_TAXONOMY); }
   "IMPORT"{SPACE}"SOURCES"    { return token(Terminals.IMPORT_SRCS); }
   "IMPORT"{SPACE}"CONCEPTS"   { return token(Terminals.IMPORT_CONCEPTS); }
   "IMPORT"{SPACE}"FILTERS"    { return token(Terminals.IMPORT_FILTERS); }
   ("DEF"|"DEFINE"){SPACE}"SOURCES"          { return token(Terminals.DEF_SRCS); }
   ("DEF"|"DEFINE"){SPACE}"CONCEPTS"         { return token(Terminals.DEF_CPTS); }
   ("DEF"|"DEFINE"){SPACE}"FILTERS"          { return token(Terminals.DEF_FILTERS); }
   ("DEF"|"DEFINE"){SPACE}("TOPIC"|"ISSUE")  { return token(Terminals.DEF_TOPIC); }
   "END"{SPACE}("CONCEPTS"|"SOURCES"|"ISSUE"|"CATEGORIES"|"TOPIC") | "END" { return token(Terminals.END); }
	"FILTER"                    { return token(Terminals.FILTER); }
   "MONITOR"{SPACE}"SOURCES"   { return token(Terminals.MONITOR_SRCS); }
   "ORGANIZE"{SPACE}"NEWS"{SPACE}"INTO"{SPACE}"CATEGORIES" { return token(Terminals.ORGANIZE_CATS); }
	"MIN_MATCH_SCORE"|"MIN-MATCH-SCORE"   { return token(Terminals.MIN_MATCH_SCORE); }
	"MIN_CONCEPT_HITS"|"MIN-CONCEPT-HITS" { return token(Terminals.MIN_CONCEPT_HITS); }
	"FROM"{SPACE}"OPML" { return token(Terminals.FROM_OPML); }
	{NUMBER}                    { return token(Terminals.NUM_TOK); }
	{WORD}                      { return token(Terminals.IDENT_TOK); }
	"(<xml.*?>)?(<opml.*</opml>)" { /* IGNORE */ }
   "#"[^\n\r]*(\n|\r)          { /* COMMENT ... IGNORE */ }
}

<COMMENT>{
	[^*]*      { }
	"*"+[^*)]* { }
	"*"+")"    { yybegin(YYINITIAL); }
}

<STRING> {
		/** Multi-line strings are not allowed!! **/
  \"             { yybegin(YYINITIAL); 
                   return token(Terminals.STRING_TOK, string.toString()); }
  [^\n\r\"\\]+   { string.append(yytext()); }
  \\\"           { string.append('\"'); }
  \\             { string.append('\\'); }
}

.                { throw new Scanner.Exception(yyline + 1, yycolumn + 1, "unrecognized character '" + yytext() + "'"); }
