package newsrack.filter.parser;

import beaver.Symbol;
import beaver.Scanner;
import newsrack.filter.parser.NR_ReferenceParser.Terminals;

%%

%pack
%unicode
%class NR_ReferenceScanner
%extends Scanner
%function nextToken
%type Symbol
%yylexthrow Scanner.Exception
%eofval{
	return new Symbol(Terminals.EOF, "end-of-file");
%eofval}

WORD   = [a-zA-Z_][0-9a-zA-Z_]*
NUMBER = [0-9]+
WS     = [ \t\n\r]
SPACE  = {WS}+

%state COMMENT

%{
   public Symbol token(short tok) 
	{
		System.out.println("token - " +  yytext() + ", " + tok); 
		return new Symbol(tok);
	}
%}

%%
{SPACE}                            { }
"(*"                               { yybegin(COMMENT); }
<COMMENT>[^*]*                     { }
<COMMENT>"*"+[^*)]*                { }
<COMMENT>"*"+")"                   { yybegin(YYINITIAL); }
"{"										  { return token(Terminals.LBRACE); }
"}"                                { return token(Terminals.RBRACE); }
"("										  { return token(Terminals.LPAREN); }
")"                                { return token(Terminals.RPAREN); }
"["										  { return token(Terminals.LBRACKET); }
"]"                                { return token(Terminals.RBRACKET); }
"<"										  { return token(Terminals.LANGLE); }
">"                                { return token(Terminals.RANGLE); }
"-"                                { return token(Terminals.HYPHEN); }
"="                                { return token(Terminals.EQUAL); }
":"                                { return token(Terminals.COLON); }
"."                                { return token(Terminals.DOT); }
","                                { return token(Terminals.COMMA); }
"|"                                { return token(Terminals.PIPE); }
"OR"                               { return token(Terminals.OR); }
"AND"                              { return token(Terminals.AND); }
"FROM"                             { return token(Terminals.FROM); }
"IMPORT"{SPACE}"SOURCES"           { return token(Terminals.IMPORT_SRCS); }
"IMPORT"{SPACE}"CONCEPTS"          { return token(Terminals.IMPORT_CONCEPTS); }
"IMPORT"{SPACE}"CATEGORIES"        { return token(Terminals.IMPORT_CATS); }
"DEFINE"{SPACE}"SOURCES"           { return token(Terminals.DEF_SRCS); }
"DEFINE"{SPACE}"CONCEPTS"          { return token(Terminals.DEF_CPTS); }
"DEFINE"{SPACE}"CATEGORIES"        { return token(Terminals.DEF_CATS); }
"DEFINE"{SPACE}"ISSUE"             { return token(Terminals.DEF_ISSUE); }
"END"{SPACE}"SOURCES"              { return token(Terminals.END_SRCS); }
"END"{SPACE}"CONCEPTS"             { return token(Terminals.END_CPTS); }
"END"{SPACE}"CATEGORIES"           { return token(Terminals.END_CATS); }
"END"{SPACE}"ISSUE"                { return token(Terminals.END_ISSUE); }
"MONITOR"{SPACE}"SOURCES"          { return token(Terminals.MONITOR_SRCS); }
"ORGANIZE"{SPACE}"NEWS"{SPACE}"INTO"{SPACE}"CATEGORIES"
	                                { return token(Terminals.ORGANIZE_CATS); }
"http://"[^ \t\n\r]*               { return token(Terminals.URL_TOK); }
{WORD}([\.|-]({WORD}|{NUMBER}))*   { return token(Terminals.STRING_TOK); }
{WORD}\."*"                        { return token(Terminals.STRING_TOK); }
{NUMBER}                           { return token(Terminals.NUM_TOK); }
"#"[^\n\r]*(\n|\r)                 { /* COMMENT ... IGNORE */ }
.                                  { throw new Scanner.Exception(yyline + 1, yycolumn + 1, "unrecognized character '" + yytext() + "'"); }
