%package "newsrack.filter.parser";
%class "NR_ReferenceParser";

%embed {:
	static public void main(String[] args) {
		try {
			int    i = 0;
			Parser p = new NR_ReferenceParser();
			while (i < args.length) {
				System.out.println("--- BEGIN PARSING file " + args[i] + " ---");
				p.parse(new newsrack.filter.parser.NR_ReferenceScanner(new java.io.FileInputStream(args[i])));
				System.out.println("--- DONE PARSING file " + args[i] + " ---");
				i++;
			}
		}
		catch (java.lang.Exception e) {
			System.err.println("Caught exception " + e);
		}
	}

	static private Symbol DEBUG(String nt) { System.out.println("PARSE: Matched " + nt); return new Symbol(""); }
:}
;

%terminals URL_TOK, STRING_TOK, NUM_TOK;
%terminals OR;					/* "OR" */
%terminals AND;				/* "AND */
%terminals IMPORT_OPML, IMPORT_SRCS, IMPORT_CONCEPTS, IMPORT_FILTERS;
%terminals FROM, MONITOR_SRCS, ORGANIZE_FILTERS;
%terminals DEF_SRCS, DEF_CPTS, DEF_FILTERS, DEF_ISSUE;
%terminals END, END_SRCS, END_CPTS, END_FILTERS, END_ISSUE;

%terminals LBRACKET, RBRACKET; 
%terminals LBRACE, RBRACE; 
%terminals LPAREN, RPAREN; 
%terminals LANGLE, RANGLE; 
%terminals DOT, COMMA, COLON, HYPHEN, PIPE, EQUAL;

%goal Profile;

Profile           = Blocks ;
Blocks            = Block
                  | Blocks Block
                  ;
Block             = Import_Directive
                  | Sources
                  | Concepts
                  | Filters
                  | Issue
                  ;
Collection_Id     = LBRACE Id RBRACE     {: return DEBUG("Collection_Id"); :} ;
Source_Id         = Src_Id               {: return DEBUG("Source_Id"); :} ;
Concept_Id        = LANGLE Id RANGLE     {: return DEBUG("Concept_Id"); :} ;
Filter_Id         = LBRACKET Id RBRACKET {: return DEBUG("Filter_Id"); :} ;
Issue_Id          = Id                   {: return DEBUG("Issue_Id"); :} ;
Src_Id            = Id ;
Id                = String ;
Url               = URL_TOK ;
Name              = String ;
String            = STRING_TOK
                  | String STRING_TOK
                  | String NUM_TOK
						;
Import_Directive  = Import_Command Id {: return DEBUG("Import_Directive"); :} 
                  | Import_Command Id FROM Id {: return DEBUG("Import_Directive"); :}
                  | Collection_Id EQUAL Import_Command Id FROM Id {: return DEBUG("Import_Directive"); :}
						| Collection_Id EQUAL Import_Command Id {: return DEBUG("Import_Directive"); :}
                  ;
Import_Command    = IMPORT_SRCS
                  | IMPORT_CONCEPTS
                  | IMPORT_FILTERS
                  ;
Sources           = DEF_SRCS Collection_Id Source_Defns END_SRCS {: return DEBUG("Source Collection"); :}
                  ;
Source_Defns      = Source_Defn
                  | Source_Defns Source_Defn
                  ;
Source_Defn       = Source_Id EQUAL Name COMMA Url {: return DEBUG("Source_Defn"); :}
						| Source_Id EQUAL Url {: return DEBUG("Source_Defn"); :}
						| Url {: return DEBUG("Source_Defn"); :}
						| IMPORT_OPML Url {: return DEBUG("OPML source"); :}
                  ;
Concepts          = DEF_CPTS Collection_Id Concept_Decls END_CPTS {: return DEBUG("Concept Collection"); :}
                  ;
Concept_Decls     = Concept_Decl
                  | Concept_Decls Concept_Decl
                  ;
Concept_Decl      = Concept_Id EQUAL Keywords {: return DEBUG("Concept_Decl"); :}
						;
Keywords          = String
                  | HYPHEN String
                  | Cpt_Macro_Use_Id
                  | Keywords.slist COMMA String
                  | Keywords.slist COMMA HYPHEN String
                  | Keywords.slist COMMA Cpt_Macro_Use_Id
                  ;
Filters           = DEF_FILTERS Collection_Id Filter_Decls END_FILTERS {: return DEBUG("Concept Collection"); :}
                  ;
Filter_Decls      = Filter_Decl {: return DEBUG("Filter_Decl"); :}
                  | Collection_Id {: return DEBUG("Collection Filter_Decl"); :}
                  | Filter_Decls Filter_Decl {: return DEBUG("Filter_Decls"); :}
                  | Filter_Decls Collection_Id {: return DEBUG("Collection Filter_Decls"); :}
                  ;
Filter_Decl       = Filter_Id EQUAL Filter_Rule {: return DEBUG("Filter_Decl"); :}
                  | Filter_Id EQUAL LBRACE Filter_Decls RBRACE {: return DEBUG("Nested Filter_Decl"); :}
                  ;
Rule_Term         = Id {: return DEBUG("RULE_TERM"); :}
                  | HYPHEN Id {: return DEBUG("RULE_TERM"); :}
                  | Collection_Id COLON Id {: return DEBUG("RULE_TERM"); :}
                  | HYPHEN Collection_Id COLON Id {: return DEBUG("RULE_TERM"); :}
                  | PIPE Context PIPE DOT Id {: return DEBUG("Context RULE_TERM"); :}
                  | PIPE Context PIPE DOT Collection_Id COLON Id {: return DEBUG("Context RULE_TERM"); :}
                  | LPAREN Filter_Rule RPAREN {: return DEBUG("Paran RULE_TERM"); :}
                  | Filter_Id {: return DEBUG("RULE_TERM"); :}
                  | HYPHEN Filter_Id {: return DEBUG("RULE_TERM"); :}
						;
Filter_Rule       = Rule_Term
                  | Filter_Rule AND Rule_Term {: return DEBUG("AND Filter_Rule"); :}
                  | Filter_Rule OR Rule_Term {: return DEBUG("OR Filter_Rule"); :}
                  ;
Context           = Id
                  | Context COMMA Id
                  ;
Issue             = IssueStartDecl IssueEndDecl ;
IssueStartDecl    = DEF_ISSUE Issue_Id ;
IssueEndDecl      = Issue_Decl END_ISSUE {: return DEBUG("Issue"); :} ;
Issue_Decl        = Import_Directives Source_Use_Decl Import_Directives Filter_Use_Decl {: return DEBUG("Issue"); :}
                  | Import_Directives Source_Use_Decl Filter_Use_Decl {: return DEBUG("Issue"); :}
                  | Source_Use_Decl Import_Directives Filter_Use_Decl {: return DEBUG("Issue"); :}
                  | Source_Use_Decl Filter_Use_Decl {: return DEBUG("Issue"); :}
                  ;
Import_Directives = Import_Directives Import_Directive
                  | Import_Directive
						;
Source_Use_Decl   = MONITOR_SRCS Source_Uses ;
Source_Uses       = Source_Use {: return DEBUG("Source_Uses"); :}
                  | Collection_Id {: return DEBUG("Source_Uses"); :}
                  | Source_Uses COMMA Source_Use {: return DEBUG("Source_Uses"); :}
                  | Source_Uses COMMA Collection_Id {: return DEBUG("Source_Uses"); :}
                  ;
Source_Use        = Src_Id
                  | Collection_Id COLON Src_Id
                  | HYPHEN Src_Id
                  | HYPHEN Collection_Id COLON Src_Id
                  ;
Filter_Use_Decl   = ORGANIZE_FILTERS LBRACE Filter_Decls RBRACE
                  | ORGANIZE_FILTERS Filter_Uses
                  ;
Filter_Uses       = Filter_Use {: return DEBUG("Filter_Uses"); :}
                  | Collection_Id {: return DEBUG("Collection Filter_Uses"); :}
                  | Filter_Uses COMMA Filter_Use {: return DEBUG("Filter_Uses"); :}
                  | Filter_Uses COMMA Collection_Id {: return DEBUG("Collection Filter_Uses"); :}
                  ;
Filter_Use        = Id {: return DEBUG("Filter_Use"); :}
                  | Collection_Id COLON Id {: return DEBUG("Collection Filter_Use"); :}
                  ;
