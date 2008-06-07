%package "newsrack.filter.parser";

%import "java.util.Hashtable";
%import "java.util.Enumeration";
%import "java.util.Iterator";
%import "java.util.List";
%import "java.util.Set";
%import "java.util.HashSet";
%import "java.util.ArrayList";
%import "java.util.Stack";
%import "newsrack.GlobalConstants";
%import "newsrack.filter.UserFile";
%import "newsrack.filter.Issue";
%import "newsrack.filter.Concept";
%import "newsrack.filter.Category";
%import "newsrack.filter.Filter.FilterOp";
%import "newsrack.filter.Filter.RuleTerm";
%import "newsrack.filter.Filter.LeafConcept";
%import "newsrack.filter.Filter.LeafCategory";
%import "newsrack.filter.Filter.NegTerm";
%import "newsrack.filter.Filter.ContextTerm";
%import "newsrack.filter.Filter.NonLeafTerm";
%import "newsrack.archiver.Source";
%import "newsrack.user.User";
%import "newsrack.filter.NR_Collection";
%import "newsrack.filter.NR_CollectionType";
%import "newsrack.filter.NR_SourceCollection";
%import "newsrack.filter.NR_ConceptCollection";
%import "newsrack.filter.NR_CategoryCollection";
%import "newsrack.util.Triple";
%import "newsrack.util.ParseUtils";
%import "org.apache.commons.logging.Log";
%import "org.apache.commons.logging.LogFactory";

%class "NRLanguageParser";

%embed {:
	private User      _user;	// Current user
	private String    _uid;		// Shortcut for _user.getUid()
	private boolean   _isFirstPass;
	private boolean   _haveUnresolvedRefs;
	private Iterator  _files;
	private UserFile  _currFile;
	private Symbol    _currSym;

	private class NRParserEvents extends Parser.Events
	{
		public void syntaxError(Symbol s)
		{
			if (s.value != null)
				ParseUtils.parseError(_currFile, Symbol.getLine(s.getStart()), "ERROR: Encountered token <b>" + s.value + "</b>");
			else
				ParseUtils.parseError(_currFile, Symbol.getLine(s.getStart()), "Syntax error");
		}
	}

   	// Logging output for this plug in instance.
   static private Log _log = LogFactory.getLog(NRLanguageParser.class);

		// Keeps track of profiles in the process of being parsed
		// (to prevent infinite recursion)
	static private Hashtable _userProfilesBeingParsed = new Hashtable();
		// Value to record name conflicts
	static private final String NAME_CONFLICT = "";
		// Returned to meet Beaver requirements
	static private final Symbol DUMMY_SYMBOL = new Symbol("");

		// Stack of parsing scopes!
	static Stack _scopeStack;

	public void parseFiles(User u, Iterator files)
	{
			// Override the error reporting module
		super.report = new NRParserEvents();

		_user  = u;
		_uid   = u.getUid();
		_files = files;
		_isFirstPass = true;
		_haveUnresolvedRefs = false;

			// Create a scope stack
		_scopeStack = new Stack();

		_userProfilesBeingParsed.put(_uid, u);
		while(true) {
				// If we are in the second pass, note that the 1st pass's scope will be on the stack
				// and its contents will be accessible!
			_scopeStack.push(new Scope());
			while (files.hasNext()) {
					// IMPORTANT NOTE: the files iterator will be potentially
					// traversed by recursive calls and so even though there might
					// be 10 files, it might happen that this loop might only
					// be executed once (the other 9 will be executed by
					// nested calls to another parser object to parse the rest of
					// the files).  Look at "parseOtherFiles()" method.
				try {
					parseFile((String)files.next());
				}
				catch (java.lang.Exception e) {
					_log.error("Parse Error!", e);
					ParseUtils.parseError(_currFile, e.toString());
				}
			}

				// Check if we need to do a second pass!
			if (_isFirstPass && _haveUnresolvedRefs) {
				_isFirstPass = false;
				_haveUnresolvedRefs = false;
			}
			else {
				break;
			}
		}

			// If we have successfully parsed the profile, add all defined collections to the user's account.
		if (!ParseUtils.encounteredParseErrors(_user)) {
			Set definedCollections = getCurrentScope()._definedCollections;
			for (Object o: definedCollections) {
				NR_Collection c = (NR_Collection)o;
				if (c._creator.getUid().equals(_uid))
					c._creator.addCollection(c);
			}
		}

		_userProfilesBeingParsed.remove(_uid);
	}

	private void parseFile(String f) throws java.lang.Exception
	{
		if (_log.isInfoEnabled()) INFO("***** Beginning parse of file " + f + " ******");
		_currFile = new UserFile(_user, f);
		parse(new NRLanguageScanner(_currFile.getFileReader()));
		if (_log.isInfoEnabled()) INFO("***** End parse of file " + f + " ******");
	}

	private boolean parseOtherFiles(String uid)
	{
		if (uid.equals(_uid)) {
			if (_files.hasNext()) {
					/* Parse other profile files -- RECURSIVE CALL */
				if (_log.isInfoEnabled()) INFO("***** BEGIN RECURSIVE PARSE *****");
				(new NRLanguageParser()).parseFiles(_user, _files);
				if (_log.isInfoEnabled()) INFO("***** END RECURSIVE PARSE *****");
				return true;
			}
			else {
					// No change in status
				return false;
			}
		}
		else {
			User u = User.getUser(uid);
			if (u.isValidated() || _userProfilesBeingParsed.containsKey(uid)) {
					// No change in status
				return false;
			}
			else {
					// RECORD THAT 'u' is being validated ...
				try {
					u.parseProfileFiles();
					return true;
				}
				catch (java.lang.Exception e) {
						// Parsing error ... No change in status
					_log.error("Parse Error!", e);
					ParseUtils.parseError(_currFile, e.toString());
					return false;
				}
			}
		}
	}

	/* Scope implements scoping functionality for imports & definitions 
	 * There is a top-level scope, and a first-level scope for issues.
	 * Scope nesting never gets greater than two at this time!  */
	static private class Scope
	{
		Issue     _i;
		Hashtable _allCollections;
		Set       _definedCollections;
		Hashtable _allSrcs;
		Hashtable _allCpts;
		Hashtable _allCats;

		private void init(Issue i)
		{
			_i = i;
			_allCollections = new Hashtable();
			_definedCollections = new HashSet();
			_allSrcs = new Hashtable();
			_allCpts = new Hashtable();
			_allCats = new Hashtable();
		}

		Scope(Issue i) { init(i); }

		Scope() { init(null); }

		void setIssue(Issue i) { _i = i; }
	}

	private void  pushScope(Issue i) { _scopeStack.push(new Scope(i)); }
	private Issue popScope()         { return ((Scope)_scopeStack.pop())._i; }
	private Scope getCurrentScope()  { return (Scope)_scopeStack.peek(); }
	private Issue getCurrentIssue()  { return getCurrentScope()._i; }

	private void recordSource(Source src)
	{
		Scope  s = getCurrentScope();
		Object o = s._allSrcs.put(src.getTag(), src);
		if (o != null)
			s._allSrcs.put(src.getTag(), NAME_CONFLICT);
	}

	private void recordConcept(Concept c)
	{
		Scope  s = getCurrentScope();
		Object o = s._allCpts.put(c.getName(), c);
		if (o != null)
			s._allCpts.put(c.getName(), NAME_CONFLICT);
	}

	private void recordCategory(Category c)
	{
		Scope  s = getCurrentScope();
		Object o = s._allCats.put(c.getName(), c);
		if (o != null)
			s._allCats.put(c.getName(), NAME_CONFLICT);
	}

	private void recordSourceCollection(String cName, List<Source> srcs)
	{
		NR_Collection nc = new NR_SourceCollection(_user, cName, srcs);
		Scope         s  = getCurrentScope();
		s._allCollections.put(NR_CollectionType.SOURCE + ":" + _uid + ":" + cName, nc);
		s._definedCollections.add(nc);
	}

	private void recordSourceCollection(String cName, Set<Source> srcSet)
	{
		List  srcs = new ArrayList();
		srcs.addAll(srcSet);
		NR_Collection nc = new NR_SourceCollection(_user, cName, srcs);
		Scope s    = getCurrentScope();
		s._allCollections.put(NR_CollectionType.SOURCE + ":" + _uid + ":" + cName, nc);
		s._definedCollections.add(nc);
	}

	private void recordConceptCollection(String cname, List cpts)
	{
		NR_Collection nc = new NR_ConceptCollection(_user, cname, cpts);
		Scope         s  = getCurrentScope();
		s._allCollections.put(NR_CollectionType.CONCEPT + ":" + _uid + ":" + cname, nc);
		s._definedCollections.add(nc);

			// Set the collection value for the concept
			// All concepts are part of some collection or the other!
		Iterator it = cpts.iterator();
		while (it.hasNext()) {
			((Concept)it.next()).setCollectionName(cname);
		}
	}

	private void recordCategoryCollection(String c, List cats)
	{
		NR_Collection nc = new NR_CategoryCollection(_user, c, cats);
		Scope         s  = getCurrentScope();
		s._allCollections.put(NR_CollectionType.CATEGORY + ":" +_uid + ":" + c, nc);
		s._definedCollections.add(nc);
	}

	private NR_Collection importCollection(String newColl, NR_CollectionType cType, String fromUid, String cid)
	{
		Scope         s = getCurrentScope();
		NR_Collection c = null;
		boolean getFromMyself = fromUid.equals(_uid);

			// 1st attempt ...
		if (getFromMyself) {
			int i = _scopeStack.size() - 1;
			while (i >= 0) {
				c = (NR_Collection)((Scope)_scopeStack.get(i))._allCollections.get(cType + ":" + _uid + ":" + cid);
				if (c != null) {
					if (!newColl.equals(cid))
						s._allCollections.put(cType + ":" +_uid + ":" + newColl, c);
					break;
				}
				i--;
			}
		}
			// No need to do this once more in the 2nd pass .. the info will already be part of the first pass scope's data ...
		else if (!_isFirstPass) {
			c = NR_Collection.getCollection(cType, fromUid, cid);
			NR_Collection.recordImportDependency(fromUid, _uid);
			if (c != null)
				s._allCollections.put(cType + ":" +_uid + ":" + newColl, c);
		}

		if ((c == null) && _isFirstPass) {
			if (parseOtherFiles(fromUid)) {
					// Try to get from other files (either from me or from another user) & try importing again
				return importCollection(newColl, cType, fromUid, cid);
			}
			else {
					// Record an unresolved ref. since this is a first pass.  Hopefully, the ref will
					// be resolved in the second pass!
				_haveUnresolvedRefs = true;
				return null;
			}
		}

		if (c == null) {
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any " + cType + " collection with name <b>" + cid + "</b> for user <b>" + fromUid + "</b>.  Did you mis-spell the collection name or user name?");

			return c;
		}
		else {
				// Add all the entries from the imported collection to the current scope
			Hashtable h;
			Iterator it;
			switch (cType) {
				case CONCEPT:
					h = s._allCpts;
					it = c.getEntries().iterator();
					while (it.hasNext()) {
						Concept o = (Concept)it.next();
						if (h.put(o.getName(), o) != null)
							h.put(o, NAME_CONFLICT); // Record a name conflict so that we can flag a conflict if this name is referenced
					}
					break;

				case CATEGORY:
					h = s._allCats;
					it = c.getEntries().iterator();
					while (it.hasNext()) {
						Category o = (Category)it.next();
						if (h.put(o.getName(), o) != null)
							h.put(o, NAME_CONFLICT); // Record a name conflict so that we can flag a conflict if this name is referenced
					}
					break;

				case SOURCE:
					h = s._allSrcs;
					it = c.getEntries().iterator();
					while (it.hasNext()) {
						Source o = (Source)it.next();
						if (h.put(o.getTag(), o) != null)
							h.put(o, NAME_CONFLICT); // Record a name conflict so that we can flag a conflict if this name is referenced
					}
					break;

				default:
					break;
			}

			return c;
		}
	}

	private NR_Collection importCollection(String newColl, NR_CollectionType cType, String cid)
	{
		return importCollection(newColl, cType, _uid, cid);
	}

	private Concept getConcept(String c)
	{
		if (_log.isDebugEnabled()) DEBUG_OUT("getConcept: Looking for " + c);

		int i = _scopeStack.size() - 1;
		while (i >= 0) {
			Object o = ((Scope)_scopeStack.get(i))._allCpts.get(c);
			if (o == NAME_CONFLICT) {
					// record conflict as a parsing error
				ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Multiple concepts found with name <b>" + c + "</b>.  Please specify the one you want by qualifying the use with the collection id. Example: Use \"{Agriculture Concepts}.farming\" rather than \"farming\" where \"{Agriculture Concepts}\" is a concept set you have defined that contains the \"farming\" concept you want to use.");
				return null;
			}
			else if (o != null) {
				if (_log.isDebugEnabled()) DEBUG_OUT("Returning " + o);
				return (Concept)o;
			}

			i--;
		}

			// Ignore error if this is the first pass ... 
		if (_isFirstPass) {
			_haveUnresolvedRefs = true;
		}
		else {
			// Parse error
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any concept with name <b>" + c + "</b>.  Did you (a) forget to define what the concept is (b) forget to import the collection where it is defined (c) mis-spell the name?");
		}
		return null;
	}

	private Concept getConcept(String cc, String c)
	{
		if (_log.isDebugEnabled()) DEBUG_OUT("getConcept: Looking for " + cc + ":" + c);

		boolean found = false;
		int     i     = _scopeStack.size() - 1;
		while (i >= 0) {
			Object nrc = ((Scope)_scopeStack.get(i))._allCollections.get(NR_CollectionType.CONCEPT + ":" +_uid + ":" + cc);
			if (nrc != null) {
				found = true;
				Concept o = ((NR_ConceptCollection)nrc).getConcept(c);
				if (o != null)
					return o;
			}

			i--;
		}

			// Ignore error if this is the first pass ... 
		if (_isFirstPass) {
			_haveUnresolvedRefs = true;
		}
		else {
			if (found) {
				ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any concept with name <b>" + c + "</b> in the collection named <b>" + cc + "</b>. Did you (a) forget to define what the concept is (b) import the wrong collection (c) mis-spell the concept or collection name?");
			}
			else {
				ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any concept collection with name <b>" + cc + "</b>.  Did you (a) mis-spell the collection name? (b) forget to import the collection?");
			}
		}
		return null;
	}

	private Category getCategory(String c)
	{
		if (_log.isDebugEnabled()) DEBUG_OUT("getCategory: Looking for " + c);

		int i = _scopeStack.size() - 1;
		while (i >= 0) {
			Object o = ((Scope)_scopeStack.get(i))._allCats.get(c);
			if (o == NAME_CONFLICT) {
					// record conflict as a parsing error
				ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Multiple categories found with name <b>" + c + "</b>.  Please specify the one you want by qualifying the use with the collection id. Example: Say \"{agriculture}.farming\" rather than \"farming\".");
				return null;
			}
			else if (o != null) {
				return (Category)o;
			}

			i--;
		}

			// Ignore error if this is the first pass ... 
		if (_isFirstPass) {
			_haveUnresolvedRefs = true;
		}
		else {
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any category with name <b>" + c + "</b>.  Did you (a) forget to define what the category is (b) forget to import the collection where it is defined (c) mis-spell the name?");
		}

		return null;
	}

	private Category getCategory(String cc, String c)
	{
		if (_log.isDebugEnabled()) DEBUG_OUT("getCategory: Looking for " + cc + ":" + c);

		boolean found = false;
		int     i     = _scopeStack.size() - 1;
		while (i >= 0) {
			Object nrc = ((Scope)_scopeStack.get(i))._allCollections.get(NR_CollectionType.CATEGORY + ":" +_uid + ":" + cc);
			if (nrc != null) {
				found = true;
				Category o = ((NR_CategoryCollection)nrc).getCategory(c);
				if (o != null) {
					return (Category)o;
				}
			}

			i--;
		}

			// Ignore error if this is the first pass ... 
		if (_isFirstPass) {
			_haveUnresolvedRefs = true;
		}
		else {
			if (found) {
				ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any category with name <b>" + c + "</b> in the collection named <b>" + cc + "</b>. Did you (a) forget to define what the category is (b) import the wrong collection (c) mis-spell the category or collection name?");
			}
			else {
				ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any category collection with name <b>" + cc + "</b>.  Did you (a) mis-spell the collection name? (b) forget to import the collection?");
			}
		}
		return null;
	}

	private List getCategoryCollection(String cc)
	{
		int i = _scopeStack.size() - 1;
		while (i >= 0) {
			Object o = ((Scope)_scopeStack.get(i))._allCollections.get(NR_CollectionType.CATEGORY + ":" +_uid + ":" + cc);
			if (o != null) {
				List<Category> cats = ((NR_CategoryCollection)o).getCategories();
					// Clone all the categories and clear out the category key
					// because these categories can potentially be shared between
					// topics / users.
				List<Category> clonedCats = new ArrayList<Category>();
				for (Category c: cats) {
					Category ccl = c.clone();
					ccl.setKey(null);
					clonedCats.add(ccl);
				}

				return clonedCats;
			}

			i--;
		}
			
			// Ignore error if this is the first pass ... 
		if (_isFirstPass) {
			_haveUnresolvedRefs = true;
		}
		else {
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any category collection with name <b>" + cc + "</b>.  Did you (a) mis-spell the collection name? (b) forget to import the collection?");
		}
		return null;
	}

	private Source getSource(String s)
	{
		if (_log.isDebugEnabled()) DEBUG_OUT("getSource: Looking for source " + s);

		int i = _scopeStack.size() - 1;
		while (i >= 0) {
			Object o = ((Scope)_scopeStack.get(i))._allSrcs.get(s);
			if (o == NAME_CONFLICT) {
					/* record conflict as a parsing error */
				ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Multiple sources found with name <b>" + s + "</b>.  Please specify the one you want by qualifying the use with the collection id. Example: Say \"{Business Feeds}.hindu\" rather than \"hindu\".");
				return null;
			}
			else if (o != null) {
				if (_log.isDebugEnabled()) DEBUG_OUT("getSource: Returning " + o);
				return (Source)o;
			}

			i--;
		}

			// Ignore error if this is the first pass ... 
		if (_isFirstPass) {
			_haveUnresolvedRefs = true;
		}
		else {
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any source with name <b>" + s + "</b>.  Did you (a) forget to define what the source is (b) forget to import the collection where it is defined (c) mis-spell the name?");
		}
		return null;
	}

	private Source getSource(String sc, String c)
	{
		if (_log.isDebugEnabled()) DEBUG_OUT("getSource: Looking for source " + sc + ":" + c);

		boolean found = false;
		int     i     = _scopeStack.size() - 1;
		while (i >= 0) {
			Object nrc = ((Scope)_scopeStack.get(i))._allCollections.get(NR_CollectionType.SOURCE + ":" +_uid + ":" + sc);
			if (nrc != null) {
				found = true;
				Source s = ((NR_SourceCollection)nrc).getSource(c);
				if (s != null)
					return s;
			}

			i--;
		}

			// Ignore error if this is the first pass ... 
		if (_isFirstPass) {
			_haveUnresolvedRefs = true;
		}
		else {
			if (found) {
				ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any source with name <b>" + c + "</b> in the collection named <b> " + sc + "</b> . Did you (a) forget to define what the source is (b) import the wrong collection (c) mis-spell the concept or collection name?");
			}
			else {
				ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any source collection with name <b>" + sc + "</b>.  Did you (a) mis-spell the collection name? (b) forget to import the collection?");
			}
		}
		return null;
	}

	private List<Source> getSourceCollection(String sc)
	{
		if (_log.isDebugEnabled()) DEBUG_OUT("getSourceCollection: Looking for " + _uid + ":" + sc);

		int i = _scopeStack.size() - 1;
		while (i >= 0) {
			Object o = ((Scope)_scopeStack.get(i))._allCollections.get(NR_CollectionType.SOURCE + ":" +_uid + ":" + sc);
			if (o != null)
				return ((NR_SourceCollection)o).getSources();

			i--;
		}

		if (_isFirstPass) {
			_haveUnresolvedRefs = true;
		}
		else {
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any source collection with name <b>" + sc + "</b>.  Did you (a) mis-spell the collection name? (b) forget to import the collection?");
		}

		return null;
	}

	private void addToUsedSources(Set<Source> h, String cid, String sid)
	{
		if (sid.indexOf("*") > 0) {
			/* Process the wild card */
		}
		else {
			Source s = (cid == null) ? getSource(sid) : getSource(cid, sid);
				// Can be null due to parsing errors OR because of forward references
			if (s != null)
				h.add(s);
		}
	}

	private void removeFromUsedSources(Set<Source> h, String cid, String sid)
	{
		if (sid.indexOf("*") > 0) {
			/* Process the wild card */
		}
		else {
			Source s = (cid == null) ? getSource(sid) : getSource(cid, sid);
				// Can be null due to parsing errors OR because of forward references
			if (s != null)
				h.remove(s);
		}
	}

	private void addCollectionToUsedSources(Set<Source> h, String cid)
	{
		List<Source> c = getSourceCollection(cid);
			// Can be null due to parsing errors OR because of forward references
		if (c == null)
			return;

		Iterator<Source> srcs = c.iterator();
		while (srcs.hasNext()) {
			Source s = srcs.next();
			if (_log.isDebugEnabled()) DEBUG_OUT("addCollectionToUsedSources: Adding " + s);
			h.add(s);
		}
	}

	private void removeCollectionFromUsedSources(Set<Source> h, String cid)
	{
		List<Source> c = getSourceCollection(cid);
			// Can be null due to parsing errors OR because of forward references
		if (c == null)
			return;

		Iterator<Source> srcs = c.iterator();
		while (srcs.hasNext()) {
			h.remove(srcs.next());
		}
	}

	private Set<Source> processSourceUse(Set<Source> h, Triple t)
	{
		if (t._a == Boolean.TRUE) {
			if (t._c == null)
  				addCollectionToUsedSources(h, (String)t._b);
			else
  				addToUsedSources(h, (String)t._b, (String)t._c);
		}
		else {
			if (t._c == null)
				removeCollectionFromUsedSources(h, (String)t._b);
			else
				removeFromUsedSources(h, (String)t._b, (String)t._c);
		}
		return h;
	}

      /** STATIC METHODS HERE **/
	private static void DEBUG(String nt)
	{ 
//		System.out.println("PARSE: Matched " + nt); 
		_log.debug("PARSE: Matched " + nt);
	}

	private static void DEBUG_OUT(String msg)
	{ 
//		System.out.println(msg); 
		_log.debug(msg);
	}
	private static void INFO(String msg)
	{ 
//		System.out.println(msg); 
		_log.info(msg);
	}

	static public void main(String[] args) {
		try {
			int    i = 0;
			Parser p = new NRLanguageParser();
			while (i < args.length) {
				if (_log.isDebugEnabled()) DEBUG_OUT("--- BEGIN PARSING file " + args[i] + " ---");
				p.parse(new NRLanguageScanner(new java.io.FileInputStream(args[i])));
				if (_log.isDebugEnabled()) DEBUG_OUT("--- DONE PARSING file " + args[i] + " ---");
				i++;
			}
		}
		catch (java.lang.Exception e) {
			_log.error("Caught exception " + e);
		}
	}
:}
;

%terminals URL_TOK, STRING_TOK, NUM_TOK, IDENT_TOK;
%terminals OR;					/* "OR" */
%terminals AND;				/* "AND */
%terminals IMPORT_SRCS, IMPORT_CONCEPTS, IMPORT_CATS;
%terminals DEF_SRCS, DEF_CPTS, DEF_CATS, DEF_ISSUE;
%terminals END, END_SRCS, END_CPTS, END_CATS, END_ISSUE;
%terminals FROM, MONITOR_SRCS, ORGANIZE_CATS;

%terminals LBRACKET, RBRACKET; 
%terminals LBRACE, RBRACE; 
%terminals LPAREN, RPAREN; 
%terminals LANGLE, RANGLE; 
%terminals DOT, COMMA, COLON, HYPHEN, PIPE, EQUAL;

%typeof Collection_Id     = "java.lang.String";
%typeof Source_Def_Id     = "java.lang.String";
%typeof Concept_Def_Id    = "java.lang.String";
%typeof Category_Def_Id   = "java.lang.String";
%typeof Issue_Id          = "java.lang.String";
%typeof Cpt_Use_Id        = "newsrack.filter.Concept";
%typeof Cpt_Macro_Use_Id  = "newsrack.filter.Concept";
%typeof Cat_Use_Id        = "newsrack.filter.Category";
%typeof Cat_Macro_Use_Id  = "newsrack.filter.Category";
/*
 * This behaves different from cats and concepts right now ...
 * because of the presence of wildcards!
 *
%typeof Src_Use_Id        = "newsrack.archiver.Source";
*/
%typeof Src_Use_Id        = "java.lang.String";
%typeof Ident             = "java.lang.String";
%typeof NonIdent          = "java.lang.String";
%typeof String            = "java.lang.String";
%typeof Rss_Feed          = "java.lang.String";
%typeof URL_TOK           = "java.lang.String";
%typeof STRING_TOK        = "java.lang.String";
%typeof IDENT_TOK         = "java.lang.String";
%typeof NUM_TOK           = "java.lang.String";
%typeof Import_Command    = "newsrack.filter.NR_CollectionType";
%typeof IMPORT_SRCS       = "java.lang.String";
%typeof IMPORT_CONCEPTS   = "java.lang.String";
%typeof IMPORT_CATS       = "java.lang.String";
%typeof Keywords          = "java.util.List";
%typeof Context           = "java.util.ArrayList";
%typeof Category_Decls    = "java.util.List";
%typeof Category_Defs     = "java.util.List";
%typeof Category_Uses     = "java.util.List";
%typeof Source_Decls      = "java.util.List";
%typeof Source_Uses       = "java.util.Set";
%typeof Source_Use_Decl   = "java.util.Set";
%typeof Category_Use_Decl = "java.util.List";
%typeof Source_Use        = "newsrack.util.Triple";
%typeof Import_Directive  = "newsrack.database.NR_Collection";
%typeof Source_Decl       = "newsrack.archiver.Source";
%typeof Concept_Decls     = "java.util.List";
%typeof Concept_Decl      = "newsrack.filter.Concept";
%typeof Context_Filter_Rule = "newsrack.filter.Filter.RuleTerm";
%typeof Filter_Rule       = "newsrack.filter.Filter.RuleTerm";
%typeof Rule_Term         = "newsrack.filter.Filter.RuleTerm";
%typeof Category_Def      = "newsrack.filter.Category";
%typeof IssueEnd_Decl     = "newsrack.filter.Issue";
%typeof Issue_Decl        = "newsrack.filter.Issue";
%typeof Issue             = "newsrack.filter.Issue";

%goal Profile;

Profile           = Blocks ;
Blocks            = Block
                  | Blocks Block
                  ;
Block             = Import_Directive
                  | Src_Collection
                  | Cpt_Collection
                  | Cat_Collection
                  | Issue
                  ;
Issue_Id          = Ident.name                   {: if (_log.isDebugEnabled()) DEBUG("Issue_Id"); return _symbol_name; :} ;
Collection_Id     = LBRACE Ident.name RBRACE     {: if (_log.isDebugEnabled()) DEBUG("Collection_Id"); return _symbol_name; :} ;
Source_Def_Id     = Ident.name                   {: if (_log.isDebugEnabled()) DEBUG("Source_Def_Id"); return _symbol_name; :} ;
Concept_Def_Id    = LANGLE Ident.name RANGLE     {: if (_log.isDebugEnabled()) DEBUG("Concept_Def_Id"); return _symbol_name; :} ;
Category_Def_Id   = LBRACKET Ident.name RBRACKET {: if (_log.isDebugEnabled()) DEBUG("Category_Def_Id"); return _symbol_name; :} ;
Src_Use_Id        = Ident ;
Cpt_Use_Id        = Ident.i
                    {: if (_log.isDebugEnabled()) DEBUG("Cpt_Use_Id"); _currSym = _symbol_i; return new Symbol(getConcept(i)); :}
                  | Collection_Id.c COLON Ident.i
						  {: if (_log.isDebugEnabled()) DEBUG("Cpt_Use_Id"); _currSym = _symbol_i; return new Symbol(getConcept(c, i)); :}
						;
Cpt_Macro_Use_Id  = Concept_Def_Id.i
                    {: if (_log.isDebugEnabled()) DEBUG("Cpt_Macro_Use_Id"); _currSym = _symbol_i; return new Symbol(getConcept(i)); :}
                  | Collection_Id.c COLON Concept_Def_Id.i
						  {: if (_log.isDebugEnabled()) DEBUG("Cpt_Macro_Use_Id"); _currSym = _symbol_i; return new Symbol(getConcept(c, i)); :}
						;
Cat_Use_Id        = Ident.i
                    {: 
						  	  if (_log.isDebugEnabled()) DEBUG("Cat_Use_Id"); 
							  _currSym = _symbol_i; 
							  	// This category use is potentially a sharing that is taking
								// place across topics / users.  This cat. use needs to be assigned
								// its own entry in the db!  To ensure that, clone cat, and clear out its key!
							  Category cat = getCategory(i).clone(); 
							  cat.setKey(null); 
							  return new Symbol(cat);
						  :}
                  | Collection_Id.c COLON Ident.i
						  {: 
						     if (_log.isDebugEnabled()) DEBUG("Cat_Use_Id");
							  _currSym = _symbol_i;
							  	// This category use is potentially a sharing that is taking
								// place across topics / users.  This cat. use needs to be assigned
								// its own entry in the db!  To ensure that, clone cat, and clear out its key!
							  Category cat = getCategory(c, i).clone();
							  cat.setKey(null);
							  return new Symbol(cat);
						  :}
						;
Cat_Macro_Use_Id  = Category_Def_Id.i
                    {: if (_log.isDebugEnabled()) DEBUG("Cat_Macro_Use_Id"); _currSym = _symbol_i; return new Symbol(getCategory(i)); :}
                  | Collection_Id.c COLON Category_Def_Id.i
						  {: if (_log.isDebugEnabled()) DEBUG("Cat_Macro_Use_Id"); _currSym = _symbol_i; return new Symbol(getCategory(c, i)); :}
						;
Ident             = IDENT_TOK.s              {: if (_log.isDebugEnabled()) DEBUG("Ident"); return _symbol_s; :}
                  | Ident.s1 STRING_TOK.s2   {: if (_log.isDebugEnabled()) DEBUG("Ident"); return new Symbol(new String(s1 + " " + s2)); :}
                  | Ident.s1 NUM_TOK.s2      {: if (_log.isDebugEnabled()) DEBUG("Ident"); return new Symbol(new String(s1 + " " + s2)); :}
                  | Ident.s1 IDENT_TOK.s2    {: if (_log.isDebugEnabled()) DEBUG("Ident"); return new Symbol(new String(s1 + " " + s2)); :}
						;
NonIdent          = STRING_TOK.s             {: if (_log.isDebugEnabled()) DEBUG("NonIdent"); return _symbol_s; :}
                  | String.s1 STRING_TOK.s2  {: if (_log.isDebugEnabled()) DEBUG("NonIdent"); return new Symbol(new String(s1 + " " + s2)); :}
                  | String.s1 NUM_TOK.s2     {: if (_log.isDebugEnabled()) DEBUG("NonIdent"); return new Symbol(new String(s1 + " " + s2)); :}
                  | String.s1 IDENT_TOK.s2   {: if (_log.isDebugEnabled()) DEBUG("NonIdent"); return new Symbol(new String(s1 + " " + s2)); :}
						;
String            = Ident
                  | NonIdent ;
Rss_Feed          = URL_TOK ;
Import_Directive  = Collection_Id.newColl EQUAL Import_Command.icmd Collection_Id.cid
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Import_Directive");
							  _currSym = _symbol_cid;
							  return new Symbol(importCollection(newColl, icmd, cid));
						  :}
                  | Collection_Id.newColl EQUAL Import_Command.icmd Collection_Id.cid FROM Ident.uid
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Import_Directive");
							  _currSym = _symbol_cid;
							  return new Symbol(importCollection(newColl, icmd, uid, cid));
						  :}
                  | Import_Command.icmd Collection_Id.cid
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Import_Directive");
							  _currSym = _symbol_cid;
							  return new Symbol(importCollection(cid, icmd, cid));
						  :}
                  | Import_Command.icmd Collection_Id.cid FROM Ident.uid
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Import_Directive");
							  _currSym = _symbol_cid;
							  return new Symbol(importCollection(cid, icmd, uid, cid));
						  :}
							/** THE FOLLOWING TWO ARE THERE FOR THE SAKE OF BACKWARD COMPATIBILITY **/
						| Collection_Id.newColl EQUAL Import_Command.icmd Ident.cid
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Import_Directive");
							  _currSym = _symbol_cid;
							  return new Symbol(importCollection(newColl, icmd, cid));
						  :}
                  | Collection_Id.newColl EQUAL Import_Command.icmd Ident.cid FROM Ident.uid
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Import_Directive");
							  _currSym = _symbol_cid;
							  return new Symbol(importCollection(newColl, icmd, uid, cid));
						  :}
                  ;
Import_Command    = IMPORT_SRCS     {: if (_log.isDebugEnabled()) DEBUG("Import_Command"); return new Symbol(NR_CollectionType.getType("SRC")); :}
                  | IMPORT_CONCEPTS {: if (_log.isDebugEnabled()) DEBUG("Import_Command"); return new Symbol(NR_CollectionType.getType("CPT")); :}
                  | IMPORT_CATS     {: if (_log.isDebugEnabled()) DEBUG("Import_Command"); return new Symbol(NR_CollectionType.getType("CAT")); :}
                  ;
Src_Collection    = DEF_SRCS Collection_Id.cid Source_Decls.slist EndSrcs
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Source Collection");
							  recordSourceCollection(cid, slist);
							  return DUMMY_SYMBOL;
						  :}
						| DEF_SRCS Collection_Id.cid Source_Uses.suh EndSrcs
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Source Collection");
							  recordSourceCollection(cid, suh);
							  return DUMMY_SYMBOL;
						  :}
                  ;
EndSrcs           = END | END_SRCS ;
Source_Decls      = Source_Decl.s 
						  {: 
						     List<Source> l = new ArrayList<Source>();
							  l.add(s);
							  return new Symbol(l);
						  :}
                  | Source_Decls.l Source_Decl.s {: l.add(s); return _symbol_l; :}
                  ;
Source_Decl       = Source_Def_Id.id EQUAL String.name COMMA Rss_Feed.feed 
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Source_Decl");
							  Source s = Source.buildSource(_user, id, name, feed);
							  recordSource(s);
							  return new Symbol(s);
						  :}
					   | error EQUAL.t String COMMA Rss_Feed
						  {:
						     ParseUtils.parseError(_currFile, Symbol.getLine(t.getStart()), "A source has to be defined: <b>(hindu) = Name, RSS_Feed</b>.");
							  return DUMMY_SYMBOL;
						  :}
                  ;
Cpt_Collection    = DEF_CPTS Collection_Id.cid Concept_Decls.clist EndCpts
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Concept Collection");
							  recordConceptCollection(cid, clist);
							  return DUMMY_SYMBOL;
						  :}
						  | error Ident.t Concept_Decls EndCpts
						  {:
						     ParseUtils.parseError(_currFile, Symbol.getLine(_symbol_t.getStart()), "Concept collections have to written as: <b>{Collection Name} : CONCEPTS { ... }</b>.");
							  return DUMMY_SYMBOL;
						  :}
                  ;
EndCpts           = END | END_CPTS ;
Concept_Decls     = Concept_Decl.a 
						  {: 
						     List<Concept> l = new ArrayList<Concept>();
						     l.add(a); 
							  return new Symbol(l);
						   :}
                  | Concept_Decls.l Concept_Decl.a {: l.add(a); return _symbol_l; :}
                  ;
Concept_Decl      = Concept_Def_Id.id EQUAL Keywords.kwds
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Concept_Decl");
							  Concept c = new Concept(id, kwds);
							  recordConcept(c);
							  return new Symbol(c);
						  :}
					   | error EQUAL.t Keywords
						  {:
						     ParseUtils.parseError(_currFile, Symbol.getLine(t.getStart()), "A concept name has to be written as: <b>&lt;concept&gt; = keyword1, keyword2, .. , keywordn</b>");
							  return DUMMY_SYMBOL;
						  :}
						| error EQUAL Keywords EQUAL.t
						  {:
						     ParseUtils.parseError(_currFile, Symbol.getLine(t.getStart()), "Check if you have an extraneous comma on the previous line!");
							  return DUMMY_SYMBOL;
						  :}
						;
								/** NO NEED TO allocate db-specific lists here, since the keywords will get
								 ** recreated anyway after normalization **/
Keywords          = String.s           {: List l = new ArrayList(); l.add(s); return new Symbol(l); :}
                  | HYPHEN String.s    {: List l = new ArrayList(); l.add("-"+s); return new Symbol(l); :}
                  | Cpt_Macro_Use_Id.c {: List l = new ArrayList(); l.add(c); return new Symbol(l); :}
                  | Keywords.slist COMMA String.s           {: slist.add(s); return _symbol_slist; :}
                  | Keywords.slist COMMA HYPHEN String.s    {: slist.add("-"+s); return _symbol_slist; :}
                  | Keywords.slist COMMA Cpt_Macro_Use_Id.c {: slist.add(c); return _symbol_slist; :}
                  ;
Cat_Collection    = DEF_CATS Collection_Id.cid Category_Decls.clist EndCats
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Concept Collection");
							  recordCategoryCollection(cid, clist);
							  return DUMMY_SYMBOL;
						  :}
                  ;
EndCats           = END | END_CATS ;
Category_Decls    = Category_Defs
                  | Category_Uses
						;
Category_Defs     = Category_Def.c
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Category_Decl");
						     List<Category> l = new ArrayList<Category>();
							  l.add(c);
							  return new Symbol(l);
						  :}
                  | Category_Defs.cl Category_Def.c
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Category_Decls");
							  cl.add(c);
							  return _symbol_cl;
						  :}
						;
Category_Uses     = Cat_Use_Id.c
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Category_Uses");
						     List<Category> l = new ArrayList<Category>(); 
							  l.add(c);
						     return new Symbol(l);
						  :}
                  | Collection_Id.cc
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Collection Category_Uses");
							  _currSym = _symbol_cc;
							  return new Symbol(getCategoryCollection(cc));
						  :}
                  | Category_Uses.l COMMA Cat_Use_Id.c
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Category_Uses");
							  l.add(c);
							  return _symbol_l;
						  :}
                  | Category_Uses.l COMMA Collection_Id.cc
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Collection Category_Uses");
							  _currSym = _symbol_cc;
							  l.addAll(getCategoryCollection(cc));
							  return _symbol_l;
						  :}
                  ;
Category_Def      = Category_Def_Id.id EQUAL.t Filter_Rule.r
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Category_Decl");
							  Category c = null;
							  try {
								  c = new Category(id, r);
							  }
							  catch (java.lang.Exception e1) {
								  if (!(_isFirstPass && _haveUnresolvedRefs)) {
									  _log.error("Parse Error!", e1);
									  ParseUtils.parseError(_currFile, Symbol.getLine(t.getStart()), e1.getMessage());
								  }
								     // This won't fail
								  try { c = new Category("DUMMY", new ArrayList<Category>()); } catch (java.lang.Exception e2) { }
							  }
							  recordCategory(c);
							  return new Symbol(c);
						  :}
                  | Category_Def_Id.id EQUAL.t LBRACE Category_Defs.clist RBRACE
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Nested Category_Decl"); 
							  Category c = null;
							  try {
							  	  c = new Category(id, clist);
							  }
							  catch (java.lang.Exception e1) {
								  _log.error("Parse Error!", e1);
						        ParseUtils.parseError(_currFile, Symbol.getLine(t.getStart()), e1.getMessage());
								     // This won't fail
								  try { c = new Category("DUMMY", clist); } catch (java.lang.Exception e2) { }
							  }
							  recordCategory(c);
							  return new Symbol(c);
						  :}
                  | Category_Def_Id.id EQUAL.t Collection_Id.cid
                    {:
						     if (_log.isDebugEnabled()) DEBUG("Nested Category_Decl with collections"); 
							  Category c = null;
							  try {
							  	  c = new Category(id, getCategoryCollection(cid));
							  }
							  catch (java.lang.Exception e1) {
								  _log.error("Parse Error!", e1);
						        ParseUtils.parseError(_currFile, Symbol.getLine(t.getStart()), e1.getMessage());
								     // This won't fail
								  try { c = new Category("DUMMY", getCategoryCollection(cid)); } catch (java.lang.Exception e2) { }
							  }
							  recordCategory(c);
							  return new Symbol(c);
						  :}
					   | error EQUAL.t Filter_Rule
						  {:
						     ParseUtils.parseError(_currFile, Symbol.getLine(t.getStart()), "A category has to be written as: <b>[category] = rule</b>.");
							  return DUMMY_SYMBOL;
						  :}
					   | error EQUAL.t LBRACE Category_Defs RBRACE
						  {:
						     ParseUtils.parseError(_currFile, Symbol.getLine(t.getStart()), "A category has to be written as: <b>[category] = rule</b>.");
							  return DUMMY_SYMBOL;
						  :}
					   | error EQUAL.t Collection_Id
						  {:
						     ParseUtils.parseError(_currFile, Symbol.getLine(t.getStart()), "A category has to be written as: <b>[category] = rule</b>.");
							  return DUMMY_SYMBOL;
						  :}
                  ;
Rule_Term         = Cpt_Use_Id.c
						  {:
						     if (_log.isDebugEnabled()) DEBUG("RULE_TERM");
							  return new Symbol(new LeafConcept(c));
						  :}
                  | HYPHEN Cpt_Use_Id.c
						  {:
						     if (_log.isDebugEnabled()) DEBUG("RULE_TERM");
							  return new Symbol(new NegTerm(new LeafConcept(c)));
						  :}
                  | Cat_Macro_Use_Id.c
						  {:
						     if (_log.isDebugEnabled()) DEBUG("RULE_TERM");
							  return new Symbol(new LeafCategory(c));
						  :}
                  | HYPHEN Cat_Macro_Use_Id.c
						  {:
						     if (_log.isDebugEnabled()) DEBUG("RULE_TERM");
							  return new Symbol(new NegTerm(new LeafCategory(c)));
						  :}
                  | PIPE Context.cxt PIPE DOT Context_Filter_Rule.r
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Context RULE_TERM");
							  return new Symbol(new ContextTerm(r, cxt));
						  :}
                  | LPAREN Filter_Rule.r RPAREN
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Paran RULE_TERM");
							  return _symbol_r;
						  :}
						;
	/* For context rule, only a restricted set of rules can be context-selected */
Context_Filter_Rule = Cpt_Use_Id.c
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Context_Filter_Rule");
							  return new Symbol(new LeafConcept(c));
						  :}
                  | LPAREN Filter_Rule.r RPAREN
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Paran Context_Filter_Rule");
							  return _symbol_r;
						  :}
						;
Filter_Rule       = Rule_Term.r {: return _symbol_r; :}
                  | Filter_Rule.r1 AND Rule_Term.r2
						  {:
						     if (_log.isDebugEnabled()) DEBUG("AND Filter_Rule"); 
							  return new Symbol(new NonLeafTerm(FilterOp.AND_TERM, r1, r2));
						  :}
                  | Filter_Rule.r1 OR Rule_Term.r2
						  {:
						     if (_log.isDebugEnabled()) DEBUG("OR Filter_Rule"); 
							  return new Symbol(new NonLeafTerm(FilterOp.OR_TERM, r1, r2));
						  :}
                  ;
Context           = Cpt_Use_Id.c                   {: ArrayList l = new ArrayList(); l.add(c); return new Symbol(l); :}
                  | Context.cxt COMMA Cpt_Use_Id.c {: cxt.add(c); return _symbol_cxt; :}
                  ;
Issue             = IssueStart_Decl IssueEnd_Decl.i ;
IssueStart_Decl   = DEF_ISSUE Issue_Id.i
						  {:
							  	/* Push a scope so that imports within the issue declaration
								 * are local to the issue */
							  try {
						        pushScope(new Issue(i, _user));
							  }
							  catch (java.lang.Exception e) {
									// Parsing error ... No change in status
								  _log.error("Parse Error!", e);
								  ParseUtils.parseError(_currFile, e.toString());
							  }

							  return DUMMY_SYMBOL;
						  :}
						  ;
IssueEnd_Decl     = Issue_Decl.i EndIssue 
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Issue"); 
							  popScope();
							  return _symbol_i;
						  :}
                  ;
EndIssue          = END | END_ISSUE ;
Issue_Decl        = Import_Directives Source_Use_Decl.su Import_Directives Category_Use_Decl.cu
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Issue_Decl");
							  Issue i = getCurrentIssue();
							  i.addSources(su);
							  i.addCategories(cu);
							  return new Symbol(i);
						  :}
                  | Import_Directives Source_Use_Decl.su Category_Use_Decl.cu
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Issue_Decl");
							  Issue i = getCurrentIssue();
							  i.addSources(su);
							  i.addCategories(cu);
							  return new Symbol(i);
						  :}
                  | Source_Use_Decl.su Import_Directives Category_Use_Decl.cu
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Issue_Decl");
							  Issue i = getCurrentIssue();
							  i.addSources(su);
							  i.addCategories(cu);
							  return new Symbol(i);
						  :}
                  | Source_Use_Decl.su Category_Use_Decl.cu
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Issue_Decl");
							  Issue i = getCurrentIssue();
							  i.addSources(su);
							  i.addCategories(cu);
							  return new Symbol(i);
						  :}
                  ;
Import_Directives = Import_Directive
                  | Import_Directives Import_Directive
						;

Source_Use_Decl   = MONITOR_SRCS Source_Uses.su ;
Source_Uses       = Source_Use.s
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Source_Uses");
							  	// IMPT: Create a new hashset ... because of possibility of multiple passes
							  return new Symbol(processSourceUse(new HashSet<Source>(), s));
						  :}
                  | Source_Uses.h COMMA Source_Use.s
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Source_Uses");
							  return new Symbol(processSourceUse(h, s));
						  :}
                  ;
Source_Use        = Src_Use_Id.s                              {: return new Symbol(new Triple(Boolean.TRUE, null, s)); :}
                  | Collection_Id.c                           {: return new Symbol(new Triple(Boolean.TRUE, c, null)); :}
                  | Collection_Id.c COLON Src_Use_Id.s        {: return new Symbol(new Triple(Boolean.TRUE, c, s)); :}
                  | HYPHEN Src_Use_Id.s                       {: return new Symbol(new Triple(Boolean.FALSE, null, s)); :}
                  | HYPHEN Collection_Id.c                    {: return new Symbol(new Triple(Boolean.FALSE, c, null)); :}
                  | HYPHEN Collection_Id.c COLON Src_Use_Id.s {: return new Symbol(new Triple(Boolean.FALSE, c, s)); :}
                  ;
Category_Use_Decl = ORGANIZE_CATS LBRACE Category_Decls.cu RBRACE
                  ;
