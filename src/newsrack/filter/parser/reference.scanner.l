package newsrack.filter.parser.v2;

import beaver.Symbol;
import beaver.Scanner;
import newsrack.filter.parser.v2.NR_ReferenceParser.Terminals;

// Add this rule! 
//
// [^ \t\n\r<>{}()\.\[\],:-=|]+       { return token(Terminals.STRING_TOK); }

%%

%pack
%unicode
%public
%caseless
%class NR_ReferenceScanner
%extends Scanner
%function nextToken
%type Symbol
%line
%column
%yylexthrow Scanner.Exception
%eofval{
	return new Symbol(Terminals.EOF, "end-of-file");
%eofval}

IDENT  = [:jletter:][:jletterdigit:]*
WORD   = [:jletterdigit:]+
WS     = [ \t\n\r]
SPACE  = {WS}+

%state COMMENT, STRING

%{
   StringBuffer string = new StringBuffer();
   public Symbol token(short tok, String s)
	{
		// System.out.println("token - " +  s + ", " + tok); 
		return new Symbol(tok, yyline+1, yycolumn+1, yylength(), s);
	}

   public Symbol token(short tok) 
	{
		return token(tok, yytext());
	}
%}

%%
<YYINITIAL> {
	"(*"                        { yybegin(COMMENT); }
	\"                          { string.setLength(0); yybegin(STRING); }
	{SPACE}                     { }
	"{"							    { return token(Terminals.LBRACE); }
	"}"                         { return token(Terminals.RBRACE); }
	"("							    { return token(Terminals.LPAREN); }
	")"                         { return token(Terminals.RPAREN); }
	"["							    { return token(Terminals.LBRACKET); }
	"]"                         { return token(Terminals.RBRACKET); }
	"<"							    { return token(Terminals.LANGLE); }
	">"                         { return token(Terminals.RANGLE); }
	"---""-"*                   { /** separator line (3 or more hyphens) ! ignore **/ }
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
   "END"{SPACE}"CONCEPTS"   	 { return token(Terminals.END); }	/** Backward compatibility **/
   "END"{SPACE}"SOURCES"     	 { return token(Terminals.END); }	/** Backward compatibility **/
   "END"{SPACE}"ISSUE"         { return token(Terminals.END); }	/** Backward compatibility **/
   "END"         					 { return token(Terminals.END); }
	"USE"{SPACE}"OPML"{SPACE}"FILE" { return token(Terminals.OPML_FILE); }
	"USE"{SPACE}"OPML"{SPACE}"URL"  { return token(Terminals.OPML_URL); }
	"INTO"{SPACE}"TAXONOMY"     { return token(Terminals.INTO_TAXONOMY); }
   "IMPORT"{SPACE}"SOURCES"    { return token(Terminals.IMPORT_SRCS); }
   "IMPORT"{SPACE}"CONCEPTS"   { return token(Terminals.IMPORT_CONCEPTS); }
   "IMPORT"{SPACE}"FILTERS"    { return token(Terminals.IMPORT_FILTERS); }
   "DEF"{SPACE}"SOURCES"       { return token(Terminals.DEF_SRCS); }
   "DEF"{SPACE}"CONCEPT"       { return token(Terminals.DEF_CPT); }
   "DEF"{SPACE}"CONCEPTS"      { return token(Terminals.DEF_CPTS); }
   "DEF"{SPACE}"FILTER"        { return token(Terminals.DEF_FILTER); }
   "DEF"{SPACE}"FILTERS"       { return token(Terminals.DEF_FILTERS); }
   "DEF"{SPACE}"TAXONOMY"      { return token(Terminals.DEF_TAXONOMY); }
   "DEF"{SPACE}"TOPIC"         { return token(Terminals.DEF_TOPIC); }
   "DEF"{SPACE}"ISSUE"         { return token(Terminals.DEF_TOPIC); }	/** Backward compatibility **/
	"FILTER"                    { return token(Terminals.FILTER); }
	"http://"[^ \t\n\r]*        { return token(Terminals.URL_TOK); }
	{IDENT}([\.|-]({WORD}))*    { return token(Terminals.IDENT_TOK); }
	{WORD}([\.|-]({WORD}))*     { return token(Terminals.STRING_TOK); }
	/* Ignoring wild cards for now ... 
	   {WORD}\."*"                        { return token(Terminals.STRING_TOK); } */
   "#"[^\n\r]*(\n|\r)          { /* COMMENT ... IGNORE */ }
}

<COMMENT>{
	[^*]*      { }
	"*"+[^*)]* { }
	"*"+")"    { yybegin(YYINITIAL); }
}

<STRING> {
		/** Multi-line strings are not allowed!! **/
  \"             { yybegin(YYINITIAL); return token(Terminals.STRING_TOK, string.toString()); }
  [^\n\r\"\\]+   { string.append(yytext()); }
  \\\"           { string.append('\"'); }
  \\             { string.append('\\'); }
}

.                { throw new Scanner.Exception(yyline + 1, yycolumn + 1, "unrecognized character '" + yytext() + "'"); }
