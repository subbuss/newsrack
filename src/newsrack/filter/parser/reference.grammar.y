%package "newsrack.filter.parser.v2";
%class "NR_ReferenceParser";

%embed {:
	static public void main(String[] args) {
		try {
			int    i = 0;
			Parser p = new NR_ReferenceParser();
			while (i < args.length) {
				System.out.println("--- BEGIN PARSING file " + args[i] + " ---");
				p.parse(new newsrack.filter.parser.v2.NR_ReferenceScanner(new java.io.FileInputStream(args[i])));
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

/** tokens **/
%terminals URL_TOK, IDENT_TOK, STRING_TOK, NUM_TOK;
%terminals IMPORT_SRCS, IMPORT_CONCEPTS, IMPORT_FILTERS;
%terminals FROM, WITH, INTO_TAXONOMY, OPML_URL, OPML_FILE, FILTER;
%terminals DEF_SRCS, DEF_CPT, DEF_CPTS, DEF_FILTER, DEF_FILTERS, DEF_TOPIC, DEF_TAXONOMY;
%terminals END;

/** non-word operators / modifiers **/
%terminals OR;
%terminals AND;
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
                  | Src_Collection
						| Concept
                  | Cpt_Collection
						| Filter
                  | Filter_Collection
                  | Taxonomy
						| Topic
                  ;
Collection_Id     = LBRACE Ident RBRACE  {: return DEBUG("Collection_Id"); :} ;
Opt_Collection_Id = Collection_Id? ;
Url               = URL_TOK ;
Ident             = IDENT_TOK
                  | Ident STRING_TOK
                  | Ident NUM_TOK
                  | Ident IDENT_TOK
                  | Ident AND {: return DEBUG("AND ident") :}
                  | Ident OR
						;
NonIdent          = STRING_TOK
                  | String STRING_TOK
                  | String NUM_TOK
                  | String IDENT_TOK
						| String AND {: return DEBUG("AND string") :}
						| String OR
						;
String            = Ident
                  | NonIdent ;
Concept_Id        = LANGLE Ident RANGLE  {: return DEBUG("Concept_Id"); :} ;
Filter_Id         = LBRACKET Ident RBRACKET {: return DEBUG("Filter_Id"); :} ;
Filter_Use_Id     = Filter_Id | Collection_Id COLON Filter_Id ;
Cpt_Use_Id        = Ident                     {: return DEBUG("Cpt_Use_Id"); :}
                  | Collection_Id COLON Ident {: return DEBUG("Cpt_Use_Id"); :}
						;
Cpt_Macro_Use_Id  = Concept_Id                     {: return DEBUG("Cpt_Macro_Use_Id"); :}
                  | Collection_Id COLON Concept_Id {: return DEBUG("Cpt_Macro_Use_Id"); :}
						;
Import_Directive  = Import_Command Collection_Refs {: return DEBUG("Import_Directive"); :} 
                  | Import_Command Collection_Refs FROM Ident {: return DEBUG("Import_Directive"); :}
                  | Collection_Id EQUAL Import_Command Collection_Id {: return DEBUG("Import_Directive"); :}
                  | Collection_Id EQUAL Import_Command Collection_Id FROM Ident {: return DEBUG("Import_Directive"); :}
                  ;
Import_Command    = IMPORT_SRCS
                  | IMPORT_CONCEPTS
                  | IMPORT_FILTERS
                  ;
Collection_Refs   = Collection_Id
                  | Collection_Refs COMMA? Collection_Id
						;
Src_Collection    = Sources_1_liners 
                  | Sources_multi_liners
						;
Sources_1_liners     = DEF_SRCS Collection_Id EQUAL Source_Defns ;
Sources_multi_liners = DEF_SRCS Collection_Id Source_Defns END ;

Source_Defns      = Source_Defn
                  | Source_Defns Source_Defn
                  ;
Source_Defn       = Url
                  | Url COMMA Ident
						| Ident EQUAL Url {: return DEBUG("Source_Defn"); :}
						| Ident EQUAL Url COMMA Ident {: return DEBUG("Source_Defn"); :}
						| OPML_URL Url {: return DEBUG("OPML source"); :}
						| OPML_FILE Ident {: return DEBUG("OPML source"); :}
						| Source_Ref
						| HYPHEN Source_Ref
                  ;
Source_Ref        = Ident COMMA?
                  | Collection_Id COLON Ident COMMA?
						| Collection_Id COMMA?
						;
Cpt_Collection    = DEF_CPTS Opt_Collection_Id Concept_Decls END {: return DEBUG("Concept Collection"); :} ;
Concept_Decls     = Concept_Decl
                  | Concept_Decls Concept_Decl
                  ;
Concept           = DEF_CPT Concept_Decl ;
Concept_Decl      = Concept_Id EQUAL Keywords {: return DEBUG("Concept_Decl"); :}
						;
Keywords          = String
/*                | HYPHEN String // No support yet! */
                  | Cpt_Macro_Use_Id
                  | Keywords COMMA String
/*                | Keywords COMMA HYPHEN String // No support yet! */
                  | Keywords COMMA Cpt_Macro_Use_Id
                  ;
Filter_Collection = DEF_FILTERS Opt_Collection_Id Filter_Decls END {: return DEBUG("Concept Collection"); :} ;
Filter_Decls      = Filter_Decl+ {: return DEBUG("Filter_Decl"); :}
                  ;
Filter            = DEF_FILTER Filter_Decl ;
Filter_Decl       = Filter_Id EQUAL Filter_Rule {: return DEBUG("Filter_Decl"); :} ;
Rule_Term         = Rule_Term_Leaf {: return DEBUG("RULE_TERM"); :}
                  | Collection_Id COLON Rule_Term_Leaf {: return DEBUG("RULE_TERM"); :}
                  | HYPHEN Filter_Rule {: return DEBUG("RULE_TERM"); :}
                  | LPAREN Filter_Rule RPAREN {: return DEBUG("Paran RULE_TERM"); :}
                  | PIPE Context PIPE DOT Filter_Rule {: return DEBUG("Context RULE_TERM"); :}
						;
Rule_Term_Leaf    = Cpt_Use_Id 
						| STRING_TOK
                  | Filter_Use_Id
						;
							// Left-associativity implemented below
Filter_Rule       = Rule_Term
                  | Filter_Rule AND Rule_Term {: return DEBUG("AND Filter_Rule"); :}
                  | Filter_Rule OR Rule_Term {: return DEBUG("OR Filter_Rule"); :}
                  ;
Context           = Ident
                  | Context COMMA Ident
                  ;
Taxonomy          = DEF_TAXONOMY Ident Taxonomy_Tree END ;
Taxonomy_Tree     = Tree_Nodes ;
Tree_Nodes        = Node
                  | Tree_Nodes Node
						;
Node              = Filter_Use_Id {: return DEBUG("Filter_Use"); :}
                  | Filter_Decl
						| Filter_Id EQUAL LBRACE Taxonomy_Tree RBRACE
						;
Topic             = Topic_Header WITH Filter_Rule {: return DEBUG("Topic w/ filter rule") :}
                  | Topic_Header INTO_TAXONOMY Ident {: return DEBUG("Topic w/ taxo name") :}
                  | Topic_Header INTO_TAXONOMY Taxonomy_Tree END {: return DEBUG("Topic w/ inline taxo") :}
						;
Topic_Header      = DEF_TOPIC Ident EQUAL FILTER Source_Uses ;
Source_Uses       = Source_Ref
						| HYPHEN Source_Ref
						| Source_Uses Source_Ref
						| Source_Uses HYPHEN Source_Ref
                  ;
