package newsrack.filter.parser;

import beaver.Symbol;
import beaver.Scanner;
import newsrack.filter.parser.NRLanguageParser.Terminals;

// Add this rule! 
//
// [^ \t\n\r<>{}()\.\[\],:-=|]+       { return token(Terminals.STRING_TOK); }

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
	"-"                         { return token(Terminals.HYPHEN); }
	"="                         { return token(Terminals.EQUAL); }
	":"                         { return token(Terminals.COLON); }
	"."                         { return token(Terminals.DOT); }
	","                         { return token(Terminals.COMMA); }
	"|"                         { return token(Terminals.PIPE); }
	"OR"                        { return token(Terminals.OR); }
	"AND"                       { return token(Terminals.AND); }
   "FROM"                      { return token(Terminals.FROM); }
   "IMPORT"{SPACE}"SOURCES"    { return token(Terminals.IMPORT_SRCS); }
   "IMPORT"{SPACE}"CONCEPTS"   { return token(Terminals.IMPORT_CONCEPTS); }
   "IMPORT"{SPACE}"CATEGORIES" { return token(Terminals.IMPORT_CATS); }
   "DEFINE"{SPACE}"SOURCES"    { return token(Terminals.DEF_SRCS); }
   "DEFINE"{SPACE}"CONCEPTS"   { return token(Terminals.DEF_CPTS); }
   "DEFINE"{SPACE}"CATEGORIES" { return token(Terminals.DEF_CATS); }
   "DEFINE"{SPACE}"ISSUE"      { return token(Terminals.DEF_ISSUE); }
   "END"{SPACE}"SOURCES"       { return token(Terminals.END_SRCS); }
   "END"{SPACE}"CONCEPTS"      { return token(Terminals.END_CPTS); }
   "END"{SPACE}"CATEGORIES"    { return token(Terminals.END_CATS); }
   "END"{SPACE}"ISSUE"         { return token(Terminals.END_ISSUE); }
   "END"         					 { return token(Terminals.END); }
   "MONITOR"{SPACE}"SOURCES"   { return token(Terminals.MONITOR_SRCS); }
   "ORGANIZE"{SPACE}"NEWS"{SPACE}"INTO"{SPACE}"CATEGORIES"
	                            { return token(Terminals.ORGANIZE_CATS); }
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
  \"             { yybegin(YYINITIAL); 
                   return token(Terminals.STRING_TOK, string.toString()); }
  [^\n\r\"\\]+   { string.append(yytext()); }
  \\\"           { string.append('\"'); }
  \\             { string.append('\\'); }
}

.                { throw new Scanner.Exception(yyline + 1, yycolumn + 1, "unrecognized character '" + yytext() + "'"); }
