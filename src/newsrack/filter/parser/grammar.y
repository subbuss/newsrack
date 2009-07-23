%package "newsrack.filter.parser";
%class "NRLanguageParser";

%import "java.io.Reader";
%import "java.util.Hashtable";
%import "java.util.HashMap";
%import "java.util.Enumeration";
%import "java.util.Iterator";
%import "java.util.Collection";
%import "java.util.List";
%import "java.util.Set";
%import "java.util.HashSet";
%import "java.util.ArrayList";
%import "java.util.Stack";
%import "newsrack.filter.UserFile";
%import "newsrack.filter.Issue";
%import "newsrack.filter.Concept";
%import "newsrack.filter.Category";
%import "newsrack.filter.Filter";
%import "newsrack.filter.Filter.FilterOp";
%import "newsrack.filter.Filter.RuleTerm";
%import "newsrack.filter.Filter.LeafConcept";
%import "newsrack.filter.Filter.LeafFilter";
%import "newsrack.filter.Filter.LeafCategory";
%import "newsrack.filter.Filter.NegTerm";
%import "newsrack.filter.Filter.AndOrTerm";
%import "newsrack.filter.Filter.ContextTerm";
%import "newsrack.filter.Filter.ProximityTerm";
%import "newsrack.filter.parser.NRLanguageScanner";
%import "newsrack.archiver.Source";
%import "newsrack.user.User";
%import "newsrack.filter.NR_Collection";
%import "newsrack.filter.NR_CollectionType";
%import "newsrack.filter.NR_SourceCollection";
%import "newsrack.filter.NR_ConceptCollection";
%import "newsrack.filter.NR_FilterCollection";
%import "newsrack.filter.NR_CategoryCollection";
%import "newsrack.util.Triple";
%import "newsrack.util.ParseUtils";
%import "org.apache.commons.logging.Log";
%import "org.apache.commons.logging.LogFactory";
%import "com.sun.syndication.feed.opml.*";
%import "com.sun.syndication.io.*";
%import "com.sun.syndication.io.WireFeedInput";

%embed {:
   	// Logging output for this plug in instance.
   static private Log _log = LogFactory.getLog(NRLanguageParser.class);
		// Value to record name conflicts
	static private final String NAME_CONFLICT = "NAME_CONFLICT";
		// Returned to meet Beaver requirements
	static private final Symbol DUMMY_SYMBOL = new Symbol("");

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

	private User      _user;					// Current user
	private String    _uid;						// Shortcut for _user.getUid()
	private boolean   _isFirstPass;
	private boolean   _haveUnresolvedRefs;
	private UserFile  _currFile;
	private Symbol    _currSym;
	private Stack 		_scopeStack; 			// Stack of parsing scopes!
	private Iterator<UserFile>	_files;		// Iterator of the current user's files ... needed for recursive parsing
		// These two hashmaps are used to implicitly represent a
		// directed graph of user files where there is an edge from file A to file B
		// if file A imports a collection from file B.  This graph is used to derive
		// a topologically sorted order for parsing files so that all references get
		// correctly resolved in a single second pass (if we end up with unresolved
		// references in the first pass)
	private HashMap   _collToFileMap;		// Collection name --> File that defines that collection
	private HashMap   _fileToImportsMap;	// File --> List of imports in that file
	private int       _cptCounter;			// Counter that tracks generated concepts
	private ArrayList _globalConcepts;		// Concepts defined outside of collections, system-generated concepts 

	private void parseFile(UserFile uf)
	{
		pushNewScope();

		String f = uf.getName();
		_currFile       = uf;
		_globalConcepts = new ArrayList();
		_cptCounter     = 0;

		if (_log.isInfoEnabled()) _log.info("***** Beginning parse of file " + f + " ******");

		try {
			// FIXME: Need to ignore opml files here!
			if (f.endsWith(".xml") || f.endsWith(".opml")) {
				_log.debug("Ignoring file: " + f);
			}
			else {
				parse(new NRLanguageScanner(_currFile.getFileReader()));

				_log.debug("Found " + _cptCounter + " global concepts!");
				if (_cptCounter > 0) {
					_log.debug("Recording another concept collection ...");
					recordConceptCollection(null, _globalConcepts);
				}
			}
		}
		catch (java.lang.Exception e) {
			_log.error("Parse Error!", e);
			ParseUtils.parseError(_currFile, e.toString());
		}

		popScope();

		if (_log.isInfoEnabled()) _log.info("***** End parse of file " + f + " ******");
	}

	private boolean parseFiles(boolean isFirstPass, boolean haveUnresolvedRefs, User u, Stack scopes, Iterator files, HashMap collToFileMap, HashMap fileImportsMap)
	{
			// Override the error reporting module
		super.report = new NRParserEvents();

			// Init
		_user               = u;
		_uid                = u.getUid();
		_scopeStack         = scopes;
		_collToFileMap      = collToFileMap;
		_fileToImportsMap   = fileImportsMap;
		_isFirstPass        = isFirstPass;
		_haveUnresolvedRefs = haveUnresolvedRefs;
		_files              = files;

			// Parse
		while (files.hasNext())
			parseFile((UserFile)files.next());

		return _haveUnresolvedRefs;
	}

	private boolean parseOtherFiles()
  	{
		if (_files.hasNext()) {
			if (_log.isInfoEnabled()) _log.info("***** BEGIN RECURSIVE PARSE *****");
			_haveUnresolvedRefs = (new NRLanguageParser()).parseFiles(_isFirstPass, _haveUnresolvedRefs, _user, _scopeStack, _files, _collToFileMap, _fileToImportsMap);
			if (_log.isInfoEnabled()) _log.info("***** END RECURSIVE PARSE *****");
			return true;
		}

			// No change in status!
		return false;
	}

	public void parseFiles(User u)
	{
		_isFirstPass        = true;
		_haveUnresolvedRefs = false;
		_scopeStack         = new Stack();
		_collToFileMap      = new HashMap();
		_fileToImportsMap   = new HashMap();
		_files              = u.getFiles();
		while(true) {
				// Push a scope for the entire profile!  Collections & issues are visible across files
			_scopeStack.push(new Scope());

				// Parse all the user's files now
			parseFiles(_isFirstPass, _haveUnresolvedRefs, u, _scopeStack, _files, _collToFileMap, _fileToImportsMap);

				// Check if we need to do a second pass!
			if (!_isFirstPass || !_haveUnresolvedRefs)
				break;

			_log.info("PASS 2 will begin now ... ");
			_isFirstPass = false;
			_haveUnresolvedRefs = false;

				// Clear out the parse errors from the first pass!
			ParseUtils.getParseErrors(u);

				// Pop the scope from the first pass!
			_scopeStack.pop();

				// Compute a topological sort ordering for file parsing.
				// Do this implicitly without constructing a directed graph of file dependencies!
				// Detect cycles too!
			List<UserFile> allFiles   = u.getFileList();
			List<UserFile> parseOrder = new ArrayList<UserFile>();
			Set<String> processedFiles = new HashSet<String>();
			int  numLeft        = allFiles.size();
			int  prevNumLeft    = numLeft;
			while (numLeft > 0) {
				prevNumLeft = numLeft;
					// In each pass, at least one file should get processed!
				for (Object uf: allFiles) {
					String file = ((UserFile)uf).getName();
					if (!processedFiles.contains(file)) {
						boolean ready = true;

							// For all collections that 'file' imports, check if the files defining those collections have been processed.
							// If all have been, 'file' is ready to be processed.
						List imports = (List)_fileToImportsMap.get(file);
						if (imports != null) {
							for (Object collName: imports) {
								String fname = (String)_collToFileMap.get(collName);
									// Check for readiness only if the collection is defined in some file.
									// If not, we won't make progress on this collection and falsely say that we are stuck in a cycle!
									// This is an undefined reference that will be caught in the second pass of parsing.
								if ((fname != null) && !processedFiles.contains(fname)) {
									ready = false;
									break;
								}
							}
						}

							// 'f' is ready ... add
						if (ready) {
							parseOrder.add((UserFile)uf);
							processedFiles.add(file);
							numLeft--;
							_log.info("PASS 2: Adding file " + file + " to parse order");
						}
					}
				}

					// Detect cycles
				if (numLeft == prevNumLeft) {
					_log.error("Looks like we have a cycle in parse order! Aborting parse!");
					ParseUtils.parseError(_currFile, "We are sorry!  Your profile cannot be validated and needs to be fixed up.  Email us for help in resolving this problem and enclose this message with your email!");
					break;
				}
			}

				// If we still have files to process, that means we aborted
				// the topological sort because of a cycle!  If so, quit
			if (numLeft > 0) {
				_haveUnresolvedRefs = true;
				break;
			}

				// Reparse the files, now in the right order!
			_files = parseOrder.iterator();
		}

		if (_haveUnresolvedRefs)
			_log.error("Have unresolved references even after a second pass with topological sort order!");

			// If we have successfully parsed the profile, 
			// add all defined collections and issues to the user's account.
		if (!ParseUtils.encounteredParseErrors(_user)) {
			Scope s = getCurrentScope();
			Set   definedCollections = s._definedCollections;
			for (Object o: definedCollections)
				_user.addCollection((NR_Collection)o);

			Set definedIssues = s._definedIssues;
			for (Object o: definedIssues) {
				try { 
					_user.addIssue((Issue)o);
				}
				catch (java.lang.Exception e) {
					ParseUtils.parseError(_currFile, e.toString());
				}
			}
		}
	}

	/* Scope implements scoping functionality for imports & definitions 
	 * There is a top-level scope, and a first-level scope for issues.
	 * Scope nesting never gets greater than two at this time!  */
	private class Scope
	{
		Issue     _i;
		Hashtable _allCollections;
		Hashtable _allCollEntries;
		Set       _definedCollections;
		Set       _definedIssues;

		private void init(Issue i)
		{
			_i = i;
			_allCollections = new Hashtable();
			_allCollEntries = new Hashtable();
			_definedCollections = new HashSet();
			_definedIssues      = new HashSet();
		}

		Scope(Issue i) { init(i); }

		Scope() { init(null); }

		public void addCollection(NR_Collection newC)
		{
				// Checks if we have a collection with the same name already, and if so,
				// we silently merge the two rather than flagging an error!
			String key = newC._type + ":" + newC._creator.getUid() + ":" + newC._name;
			Object o   = _allCollections.get(key);
			if (o == null) {
				_definedCollections.add(newC);
				_allCollections.put(key, newC);
			}
			else {
				((NR_Collection)o).mergeCollection(newC);
			}
		}

		public void mergeScope(Scope other)
		{
				// Merge defined collections
			int n = _scopeStack.size();
			for (Object o: other._definedCollections)
				addCollection((NR_Collection)o);

				// Merge defined issues
			_definedIssues.addAll(other._definedIssues);

			// FIXME: Do we want to merge sources, concepts & cats too?
			// Maybe not for now ... we have to separate, defined vs. all
		}

		public void addIssue(Issue i) { _definedIssues.add(i); }
	}

	private Scope getCurrentScope()  { return (Scope)_scopeStack.peek(); }
	private Issue getCurrentIssue()  { return getCurrentScope()._i; }
	private void  pushScope(Issue i) { getCurrentScope().addIssue(i); _scopeStack.push(new Scope(i)); }
	private void  pushNewScope()     { _scopeStack.push(new Scope()); }
	private Scope popScope()         { 
		Scope poppedScope = (Scope)_scopeStack.pop();
		getCurrentScope().mergeScope(poppedScope);
		return poppedScope;
	}

	private void recordSource(Source src)
	{
		Scope  s = getCurrentScope();
		String k = NR_CollectionType.SOURCE + ":" + src.getTag();
		Object o = s._allCollEntries.put(k, src);
			// Check if we have a conflict!
			// If the two source objects with the same tags are identical, we ignore the conflict!
		if ((o != null) && !src.equals(o))
			s._allCollEntries.put(k, NAME_CONFLICT);
	}

	private void recordConcept(Concept c)
	{
		Scope  s = getCurrentScope();
		String k = NR_CollectionType.CONCEPT + ":" + c.getName();
		Object o = s._allCollEntries.put(k, c);
		if (o != null)
			s._allCollEntries.put(k, NAME_CONFLICT);
	}

	private void recordFilter(Filter f)
	{
		Scope  s = getCurrentScope();
		String k = NR_CollectionType.FILTER + ":" + f.getName();
		Object o = s._allCollEntries.put(k, f);
		if (o != null)
			s._allCollEntries.put(k, NAME_CONFLICT);
	}

	private void recordCategory(Category c)
	{
		Scope  s = getCurrentScope();
		String k = NR_CollectionType.CATEGORY + ":" + c.getName();
		Object o = s._allCollEntries.put(k, c);
		if (o != null)
			s._allCollEntries.put(k, NAME_CONFLICT);
	}

	private void recordSourceCollection(String cName, Collection<Source> srcs)
	{
		if (cName == null)
			cName = "_" + _currFile.getUser().getUid() + "_" + _currFile.getName() + "_global_sources";

			// Add the new collection to the current scope!
		getCurrentScope().addCollection(new NR_SourceCollection(_currFile, cName, srcs));

			// Associate this collection with the current file
		_collToFileMap.put(NR_CollectionType.SOURCE + ":" + _uid + ":" + cName, _currFile.getName());
	}

	private void recordConceptCollection(String cname, Concept[] cpts)
	{
		ArrayList<Concept> x = new ArrayList<Concept>();
		for (int i = 0; i < cpts.length; i++)
			x.add(cpts[i]);

		recordConceptCollection(cname, x);
	}

	private void recordConceptCollection(String cName, Collection<Concept> cpts)
	{
			// If no collection name is provided, simply store them all in a single global collection (on a per-file basis)
		if (cName == null)
			cName = "_" + _currFile.getUser().getUid() + "_" + _currFile.getName() + "_global_concepts";

			// Add the new collection to the current scope!
		NR_ConceptCollection nc = new NR_ConceptCollection(_currFile, cName, cpts);
		getCurrentScope().addCollection(nc);

			// Associate this collection with the current file
		_collToFileMap.put(NR_CollectionType.CONCEPT + ":" + _uid + ":" + cName, _currFile.getName());

			// Set the containing collection for the concept
			// All concepts are part of some collection or the other!
		Iterator it = cpts.iterator();
		while (it.hasNext()) {
			((Concept)it.next()).setCollection(nc);
		}
	}

	private void recordFilterCollection(String c, Filter[] filters)
	{
		ArrayList<Filter> x = new ArrayList<Filter>();
		for (int i = 0; i < filters.length; i++)
			x.add(filters[i]);

		recordFilterCollection(c, filters);
	}

	private void recordFilterCollection(String c, Collection<Filter> filters)
	{
		if (c == null)
			c = "_" + _currFile.getUser().getUid() + "_" + _currFile.getName() + "_global_filters";

			// Add the new collection to the current scope!
		getCurrentScope().addCollection(new NR_FilterCollection(_currFile, c, filters));

			// Associate this collection with the current file
		_collToFileMap.put(NR_CollectionType.FILTER + ":" + _uid + ":" + c, _currFile.getName());
	}

	private void addCollectionEntries(Iterator it, NR_CollectionType cType)
	{
		Hashtable h = getCurrentScope()._allCollEntries;
		while (it.hasNext()) {
			Object entry = it.next();
			String key   = null;
			switch (cType) {
				case CONCEPT : key = NR_CollectionType.CONCEPT + ":" + ((Concept)entry).getName(); break;
				case CATEGORY: key = NR_CollectionType.CATEGORY + ":" + ((Category)entry).getName(); break;
				case SOURCE  : key = NR_CollectionType.SOURCE + ":" + ((Source)entry).getTag(); break;
				default: break;
			}

				// Check if we have a name conflict ... if two source objects with the same tags are identical, we ignore the conflict!
			Object old = h.put(key, entry);
			if ((old != null) && !(cType == NR_CollectionType.SOURCE && entry.equals(old)))
				h.put(key, NAME_CONFLICT);
		}
	}

	private NR_Collection importCollection(String newColl, NR_CollectionType cType, String fromUid, String cid)
	{
		Scope         s = getCurrentScope();
		NR_Collection c = null;
		boolean getFromMyself = fromUid.equals(_uid);

			// 1st attempt ...
		if (getFromMyself) {
			String uniqCollName = cType + ":" + _uid + ":" + cid;

				// Add to the list of imports in this file
			List fileImports  = (List)_fileToImportsMap.get(_currFile.getName());
			if (fileImports == null) {
				fileImports = new ArrayList();
				_fileToImportsMap.put(_currFile.getName(), fileImports);
			}
			fileImports.add(uniqCollName);

				// Try to find the collection
			int i = _scopeStack.size() - 1;
			while (i >= 0) {
				c = (NR_Collection)((Scope)_scopeStack.get(i))._allCollections.get(uniqCollName);
				if (c != null) {
					if (newColl != null && !newColl.equals(cid))
						s._allCollections.put(cType + ":" +_uid + ":" + newColl, c);
					break;
				}
				i--;
			}
		}
		else {
			c = NR_Collection.getCollection(cType, fromUid, cid);
			NR_Collection.recordImportDependency(fromUid, _uid);
			if (c != null)
				s._allCollections.put(cType + ":" +_uid + ":" + newColl, c);
		}

		if ((c == null) && _isFirstPass) {
				// Try to parse other files & try importing again
			if (getFromMyself && parseOtherFiles()) {
				return importCollection(newColl, cType, fromUid, cid);
			}
			else {
					// Record an unresolved ref. since this is a first pass.
					// Hopefully, the ref will be resolved in the second pass!
				_log.info("UNRESOLVED Import for " + cType + ":" + _uid + ":" + cid);
				_haveUnresolvedRefs = true;
				return null;
			}
		}

		if (c == null) {
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any " + cType + " collection with name <b>" + cid + "</b> for user <b>" + fromUid + "</b>.  Did you mis-spell the collection name or user name?");
		}
		else {
				// Add all the entries from the imported collection to the current scope
			addCollectionEntries(c.getEntries().iterator(), cType);
		}
		return c;
	}

	private NR_Collection importCollection(String newColl, NR_CollectionType cType, String cid)
	{
		return importCollection(newColl, cType, _uid, cid);
	}

	private Object getItemFromScope(NR_CollectionType itemType, String itemName, boolean recordError)
	{
		int i = _scopeStack.size() - 1;
		while (i >= 0) {
			Object o = ((Scope)_scopeStack.get(i))._allCollEntries.get(itemType + ":" + itemName);
			if (o != null)
				return o;

			i--;
		}

			// Ignore error if this is the first pass ... 
		if (recordError) {
			if (_isFirstPass) {
				_haveUnresolvedRefs = true;
			}
				// Parse error
			else {
				ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any " + itemType + " with name <b>" + itemName + "</b>.  Did you (a) forget to define what the " + itemType + " is (b) forget to import the collection where it is defined (c) mis-spell the name?");
			}
		}

		return null;
	}

	private Object getItemFromScope(NR_CollectionType itemType, String collName, String itemName, boolean recordError)
	{
		if (collName == null)
			return getItemFromScope(itemType, itemName, recordError);

		boolean found = false;
		int     i     = _scopeStack.size() - 1;
		while (i >= 0) {
			Object nrc = ((Scope)_scopeStack.get(i))._allCollections.get(itemType + ":" +_uid + ":" + collName);
			if (nrc != null) {
				found = true;
				Object o = ((NR_Collection)nrc).getEntryByName(itemName);
				if (o != null)
					return o;
			}

			i--;
		}

		if (recordError) {
				// Ignore error if this is the first pass ... 
			if (_isFirstPass) {
				_haveUnresolvedRefs = true;
			}
			else {
				if (found) {
					ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any " + itemType + " with name <b>" + itemName + "</b> in the collection named <b>" + collName + "</b>. Did you (a) forget to define what the " + itemType + " is (b) import the wrong collection (c) mis-spell the " + itemType + " or collection name?");
				}
				else {
					ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any " + itemType + " collection with name <b>" + collName + "</b>.  Did you (a) mis-spell the collection name? (b) forget to import the collection?");
				}
			}
		}
		return null;
	}

	private Object getItemFromScope(NR_CollectionType itemType, String collName, String itemName)
	{
		return getItemFromScope(itemType, collName, itemName, true);
	}

	private Object getItemFromScope(NR_CollectionType itemType, String itemName)
	{
		return getItemFromScope(itemType, itemName, true);
	}

	private Concept getConcept(String cc, String c)
	{
		if (_log.isDebugEnabled()) DEBUG_OUT("getConcept: Looking for " + cc + ":" + c);

		Object o = getItemFromScope(NR_CollectionType.CONCEPT, cc, c);
		if (o == NAME_CONFLICT) {
				// record conflict as a parsing error
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Multiple concepts found with name <b>" + c + "</b>.  Please specify the one you want by qualifying the use with the collection id. Example: Use \"{Agriculture Concepts}.farming\" rather than \"farming\" where \"{Agriculture Concepts}\" is a concept set you have defined that contains the \"farming\" concept you want to use.");
			return null;
		}

		return (Concept)o;
	}

	private Concept getConcept(String c) { return getConcept(null, c); }

	private Filter getFilter(String fc, String name, boolean recordParseError)
	{
		if (_log.isDebugEnabled()) DEBUG_OUT("getFilter: Looking for " + fc + ":" + name);

		Object o = getItemFromScope(NR_CollectionType.FILTER, fc, name, recordParseError);
		if (o == NAME_CONFLICT) {
				// record conflict as a parsing error
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Multiple filters found with name <b>" + name + "</b>.  Please specify the one you want by qualifying the use with the collection id. Example: Say \"{agriculture}.farming\" rather than \"farming\".");
			return null;
		}

		return (Filter)o;
	}

	private Filter getFilter(String name, boolean recordParseError) { return getFilter(null, name, recordParseError); }

	private Category getCategory(String cc, String c)
	{
		if (_log.isDebugEnabled()) DEBUG_OUT("getCategory: Looking for " + cc + ":" + c);

		Object o = getItemFromScope(NR_CollectionType.CATEGORY, cc, c);
		if (o == NAME_CONFLICT) {
				// record conflict as a parsing error
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Multiple categories found with name <b>" + c + "</b>.  Please specify the one you want by qualifying the use with the collection id. Example: Say \"{agriculture}.farming\" rather than \"farming\".");
			return null;
		}

		return (Category)o;
	}

	private Category getCategory(String c) { return getCategory(null, c); }

	private Source getSource(String sc, String s)
	{
		if (_log.isDebugEnabled()) DEBUG_OUT("getSource: Looking for " + sc + ":" + s);

		Object o = getItemFromScope(NR_CollectionType.SOURCE, sc, s);
		if (o == NAME_CONFLICT) {
				// record conflict as a parsing error
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Multiple sources found with name <b>" + s + "</b>.  Please specify the one you want by qualifying the use with the collection id. Example: Say \"{Business Feeds}.hindu\" rather than \"hindu\".");
			return null;
		}

		return (Source)o;
	}

	private Source getSource(String s) { return getSource(null, s); }

	private Collection<Source> getSourceCollection(String sc)
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
			_log.info("UNRESOLVED: ...");
			_haveUnresolvedRefs = true;
			return new ArrayList<Source>();
		}
		else {
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Did not find any source collection with name <b>" + sc + "</b>.  Did you (a) mis-spell the collection name? (b) forget to import the collection?");
			return null;
		}
	}

	private void addToUsedSources(Set<Source> h, String cid, String sid)
	{
		if (sid.indexOf("*") > 0) {
			/* Process the wild card */
			// NOT SUPPORTED YET!
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
		Collection<Source> c = getSourceCollection(cid);
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
		Collection<Source> c = getSourceCollection(cid);
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

	public Set<Source> processOPMLOutlines(List<Outline> outlines)
   {
      if (outlines == null)
         return null;

		Set<Source> srcs = new HashSet<Source>();
      for (Outline o: outlines) {
         List<Outline> children = o.getChildren();
         if ((children != null) && !children.isEmpty()) {
            Set cs = processOPMLOutlines((List<Outline>)(o.getChildren()));
				if (cs != null)
					srcs.addAll(cs);
         }
         else {
            String url = o.getXmlUrl();
            if (url == null)
               url = o.getUrl();
				Source s = Source.buildSource(_user, o.getText(), null, url); 
				recordSource(s); 
				srcs.add(s);
         }
      }

		return srcs;
   }

	private Set<Source> processOpmlSource(String f)
	{
		try {
			Reader r    = (new UserFile(_user, f)).getFileReader();
			Opml   feed = (Opml)(new WireFeedInput()).build(r);
			return processOPMLOutlines(feed.getOutlines());
		}
		catch (java.io.IOException e) {
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "OPML file not found.  Have you uploaded the opml file <b>" + f + "</b>?");
			return null;
		}
		catch (java.lang.Exception e) {
			ParseUtils.parseError(_currFile, Symbol.getLine(_currSym.getStart()), "Error processing the opml file <b>" + f + "</b>.  Verify that it is an opml file");
			return null;
		}
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

/** tokens **/
%terminals URL_TOK, IDENT_TOK, STRING_TOK, NUM_TOK;
%terminals IMPORT_SRCS, IMPORT_CONCEPTS, IMPORT_FILTERS, FROM_OPML;
%terminals FROM, WITH, INTO_TAXONOMY, FILTER;
%terminals DEF_SRCS, DEF_CPTS, DEF_FILTERS, DEF_TOPIC;
%terminals END;
%terminals MONITOR_SRCS, ORGANIZE_CATS;
%terminals MIN_MATCH_SCORE, MIN_CONCEPT_HITS;

/** non-word operators / modifiers **/
%terminals OR;
%terminals AND;
%terminals LBRACKET, RBRACKET; 
%terminals LBRACE, RBRACE; 
%terminals LPAREN, RPAREN; 
%terminals LANGLE, RANGLE; 
%terminals DOT, COMMA, COLON, TILDE, HYPHEN, PIPE, EQUAL;

%typeof Collection_Id     = "java.lang.String";
%typeof Opt_Collection_Id = "java.lang.String";
%typeof Topic_Id          = "java.lang.String";
%typeof Concept_Id        = "java.lang.String";
%typeof Filter_Id         = "java.lang.String";
%typeof Cpt_Use_Id        = "newsrack.filter.Concept";
%typeof Cpt_Macro_Use_Id  = "newsrack.filter.Concept";
%typeof LeafConcept       = "newsrack.filter.Concept";
%typeof Filt_Or_Cat_Use_Id= "java.lang.Object";	// Can be either newsrack.filter.Filter or newsrack.filter.Category
%typeof Filter_Decl       = "newsrack.filter.Filter";
%typeof IdentPrefix_1     = "java.lang.String";
%typeof IdentPrefix_2     = "java.lang.String";
%typeof SimpleIdent       = "java.lang.String";
%typeof IdentPart         = "java.lang.String";
%typeof Ident             = "java.lang.String";
%typeof Reserved_Keywords = "java.lang.String";
%typeof StringPart        = "java.lang.String";
%typeof String            = "java.lang.String";
%typeof URL_TOK           = "java.lang.String";
%typeof STRING_TOK        = "java.lang.String";
%typeof IDENT_TOK         = "java.lang.String";
%typeof NUM_TOK           = "java.lang.String";
%typeof AND               = "java.lang.String";
%typeof OR                = "java.lang.String";
%typeof FILTER            = "java.lang.String";
%typeof FROM              = "java.lang.String";
%typeof WITH              = "java.lang.String";
/**
%typeof IMPORT_SRCS       = "java.lang.String";
%typeof IMPORT_CONCEPTS   = "java.lang.String";
%typeof IMPORT_FILTERS    = "java.lang.String";
%typeof INTO_TAXONOMY     = "java.lang.String";
%typeof DEF_SRCS          = "java.lang.String";
%typeof DEF_CPTS          = "java.lang.String";
%typeof DEF_FILTERS       = "java.lang.String";
%typeof DEF_TOPIC         = "java.lang.String";
%typeof MONITOR_SRCS      = "java.lang.String";
%typeof ORGANIZE_CATS     = "java.lang.String";
**/
%typeof Import_Command    = "newsrack.filter.NR_CollectionType";
%typeof Keywords          = "java.util.List";
%typeof Context           = "java.util.ArrayList";
%typeof Node              = "newsrack.filter.Category";
%typeof Tree_Nodes        = "java.util.ArrayList";
%typeof Source_Defns      = "java.util.Set";
%typeof Source_Uses       = "java.util.Set";
%typeof Source_Defn       = "newsrack.archiver.Source";
%typeof Source_Use        = "newsrack.util.Triple";
%typeof Concept_Decl      = "newsrack.filter.Concept";
%typeof Filter_Rule       = "newsrack.filter.Filter.RuleTerm";
%typeof Rule_Term         = "newsrack.filter.Filter.RuleTerm";
%typeof Rule_Term_Leaf    = "newsrack.filter.Filter.RuleTerm";
%typeof Min_Score         = "java.lang.Integer";
%typeof Source_Use_Decl   = "java.util.Set";
%typeof Category_Use_Decl = "java.util.List";
%typeof IssueEnd_Decl     = "newsrack.filter.Issue";
%typeof Issue_Decl        = "newsrack.filter.Issue";
%typeof Legacy_Issue_Decl = "newsrack.filter.Issue";

%goal Profile;

Profile           = Blocks
                  | error 
						;
Blocks            = Block+ ;
Block             = Import_Directive
                  | Src_Collection
                  | Cpt_Collection
                  | Filter_Collection
/**
  TODO: Not supported yet!

						| Concept
						| Filter
                  | Taxonomy
**/
						| Topic
						| Legacy_Issue_Decl
                  ;
Url               = URL_TOK ;

/*
 * This whole business of identifiers is arbitrary ... I could have made everything strings except that:
 *  (1) concept-ids can appear as bare words in filters
 *  (2) source names can be written without quotes
 *  (3) keywords in concept definitions can be written without quotes
 * All these together cause a lot of parse conflicts if all identifiers were "string"s
 * So, concept ids are currently restricted, and other ids don't have all reserved words as bare words 
 */
IdentPrefix_1     = FILTER | FROM | IDENT_TOK | NUM_TOK ;
IdentPrefix_2     = FILTER | FROM | IDENT_TOK | NUM_TOK | STRING_TOK ;
IdentPart         = IdentPrefix_2 | AND | OR ;

SimpleIdent       = IdentPrefix_1 | SimpleIdent.s1 IdentPrefix_2.s2 {: DEBUG("SimpleIdent"); return new Symbol(s1 + " " + s2); :} ;
Ident             = IdentPart | Ident.s1 IdentPart.s2 {: DEBUG("String"); return new Symbol(s1 + " " + s2); :} ;

Reserved_Keywords = AND | OR | WITH | FILTER | FROM ;
StringPart        = IDENT_TOK | NUM_TOK | STRING_TOK | Reserved_Keywords ;
String            = StringPart | String.s1 StringPart.s2 {: DEBUG("String"); return new Symbol(s1 + " " + s2); :} ;

Concept_Id        = LANGLE SimpleIdent.c RANGLE {: DEBUG("Concept_Id"); return _symbol_c; :} ;
Cpt_Use_Id        = SimpleIdent.i                       {: DEBUG("Cpt_Use_Id"); _currSym = _symbol_i; return new Symbol(getConcept(i)); :}
                  | Collection_Id.c COLON SimpleIdent.i {: DEBUG("Cpt_Use_Id"); _currSym = _symbol_i; return new Symbol(getConcept(c, i)); :}
						;
Cpt_Macro_Use_Id  = Concept_Id.i                       {: DEBUG("Cpt_Macro_Use_Id"); _currSym = _symbol_i; return new Symbol(getConcept(i)); :}
                  | Collection_Id.c COLON Concept_Id.i {: DEBUG("Cpt_Macro_Use_Id"); _currSym = _symbol_i; return new Symbol(getConcept(c, i)); :}
						;
Filter_Id         = LBRACKET Ident.f RBRACKET ;
Collection_Id     = LBRACE Ident.name RBRACE ;
Opt_Collection_Id = Collection_Id? ;
Topic_Id          = Ident ;
Import_Directive  = Import_Command.icmd Collection_Refs.coll_ids
						  {:
						     DEBUG("Import_Directive");
							  _currSym = _symbol_icmd;
							  for (int i = 0; i < coll_ids.length; i++)
								  importCollection(coll_ids[i], icmd, coll_ids[i]);

						  	  return DUMMY_SYMBOL;
						  :}
                  | Import_Command.icmd Collection_Refs.coll_ids FROM IDENT_TOK.uid
						  {:
						     DEBUG("Import_Directive");
							  _currSym = _symbol_icmd;
							  for (int i = 0; i < coll_ids.length; i++)
								  importCollection(coll_ids[i], icmd, uid, coll_ids[i]);

						  	  return DUMMY_SYMBOL;
						  :}
                  | Collection_Id.newColl EQUAL Import_Command.icmd Collection_Id.cid
						  {:
						     DEBUG("Import_Directive");
							  _currSym = _symbol_icmd;
						     importCollection(newColl, icmd, cid);

						  	  return DUMMY_SYMBOL;
						  :}
                  | Collection_Id.newColl EQUAL Import_Command.icmd Collection_Id.cid FROM IDENT_TOK.uid
						  {:
						     DEBUG("Import_Directive");
							  _currSym = _symbol_icmd;
						     importCollection(newColl, icmd, uid, cid);

						  	  return DUMMY_SYMBOL;
						  :}
						| Collection_Id.srcColl EQUAL IMPORT_SRCS FROM_OPML Ident.file {: 
							  DEBUG("OPML");
							  Set<Source> srcs = processOpmlSource(file);
							  if (srcs != null) {
								  addCollectionEntries(srcs.iterator(), NR_CollectionType.SOURCE);
								  recordSourceCollection(srcColl, srcs);
							  }

						  	  return DUMMY_SYMBOL;
						  :}
						;
Import_Command    = IMPORT_SRCS     {: DEBUG("Import_Command"); return new Symbol(NR_CollectionType.getType("SRC")); :}
                  | IMPORT_CONCEPTS {: DEBUG("Import_Command"); return new Symbol(NR_CollectionType.getType("CPT")); :}
                  | IMPORT_FILTERS  {: DEBUG("Import_Command"); return new Symbol(NR_CollectionType.getType("FIL")); :}
                  ;
Collection_Refs   = Collection_Id | Collection_Refs COMMA Collection_Id ;
Src_Collection    = Source_Use_Decls | Source_Defn_Decls ;
Source_Use_Decls  = DEF_SRCS Collection_Id.c EQUAL Source_Uses.srcs END? {: recordSourceCollection(c, srcs); return DUMMY_SYMBOL; :}
                  | DEF_SRCS Collection_Id.c Source_Uses.srcs END        {: recordSourceCollection(c, srcs); return DUMMY_SYMBOL; :}
                  ;
Source_Defn_Decls = DEF_SRCS Collection_Id.c Source_Defns.srcs END       {: recordSourceCollection(c, srcs); return DUMMY_SYMBOL; :}
						;
Source_Defns      = Source_Defn.s                       {: HashSet<Source> srcs = new HashSet<Source>(); srcs.add(s); return new Symbol(srcs); :}
                  | Source_Defns.src_defs Source_Defn.s {: src_defs.add(s); return _symbol_src_defs; :}
                  ;
Source_Defn       = Url.feed                  {: Source s = Source.buildSource(_user, null, null, feed); recordSource(s); return new Symbol(s); :}
						| Ident.tag EQUAL Url.feed  {: Source s = Source.buildSource(_user, tag, null, feed);  recordSource(s); return new Symbol(s); :}
						| Ident.tag EQUAL String.name COMMA Url.feed {: Source s = Source.buildSource(_user, tag, name, feed); recordSource(s); return new Symbol(s); :}
/*
 * Leads to several parsing conflicts!
                  | String.name COMMA Url.feed {: Source s = Source.buildSource(_user, null, name, feed); recordSource(s); return new Symbol(s); :}
 */
                  ;
Source_Use        = Ident.s                              {: return new Symbol(new Triple(Boolean.TRUE, null, s)); :}
						| Collection_Id.c                      {: return new Symbol(new Triple(Boolean.TRUE, c, null)); :}
                  | Collection_Id.c COLON Ident.s        {: return new Symbol(new Triple(Boolean.TRUE, c, s)); :}
						| HYPHEN Ident.s                       {: return new Symbol(new Triple(Boolean.FALSE, null, s)); :}
						| HYPHEN Collection_Id.c               {: return new Symbol(new Triple(Boolean.FALSE, c, null)); :}
                  | HYPHEN Collection_Id.c COLON Ident.s {: return new Symbol(new Triple(Boolean.FALSE, c, s)); :}
						;
Cpt_Collection    = DEF_CPTS Opt_Collection_Id.cid Concept_Decls.cpts END {: recordConceptCollection(cid, cpts); return DUMMY_SYMBOL; :} ;
Concept_Decls     = Concept_Decl | Concept_Decls Concept_Decl ;
/**
TODO: Not supported yet
Concept           = DEF_CPT Concept_Decl ;
**/
Concept_Decl      = Concept_Id.id EQUAL Keywords.kwds 
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Concept_Decl");
							  Concept c = null;
							  try {
							     c = new Concept(id, kwds);
							  }
							  catch (java.lang.Exception e) {
								  	// We can run into errors because of unresolved definitions in the first pass
									// We ignore those here!
								  if (_isFirstPass)
									  c = new Concept("DUMMY", "");
							  }
							  recordConcept(c);
							  return new Symbol(c);
						  :}
					   | error EQUAL.t Keywords
						  {:
						     ParseUtils.parseError(_currFile, Symbol.getLine(t.getStart()), "A concept has to be defined as: <b>&lt;concept&gt; = keyword1, keyword2, .. , keywordn</b>");
							  return DUMMY_SYMBOL;
						  :}
						;
Keywords          = String.s                                {: DEBUG("Keyword: " + s); List l = new ArrayList(); l.add(s); return new Symbol(l); :}
                  | Cpt_Macro_Use_Id.c                      {: List l = new ArrayList(); l.add(c); return new Symbol(l); :}
                  | Keywords.kwds COMMA String.s            {: DEBUG("Keywords"); kwds.add(s); return _symbol_kwds; :}
                  | Keywords.kwds COMMA Cpt_Macro_Use_Id.c  {: kwds.add(c); return _symbol_kwds; :}
                  ;
Filter_Collection = DEF_FILTERS Opt_Collection_Id.cid Filter_Decls.filts END {: recordFilterCollection(cid, filts); return DUMMY_SYMBOL; :} ;
Filter_Decls      = Filter_Decl | Filter_Decls Filter_Decl ;
/**
TODO: Not supported yet
Filter            = DEF_FILTER Filter_Decl ;
**/
Filter_Decl       = Filter_Id.fid EQUAL Filter_Rule.r {: Filter f = new Filter(fid, r); recordFilter(f); return new Symbol(f); :}
                  | Filter_Id.fid Min_Score.h EQUAL Filter_Rule.r {: Filter f = new Filter(fid, r, h); recordFilter(f); return new Symbol(f); :}

                  ;
							// Left-associativity implemented below
Filter_Rule       = Rule_Term
                  | Filter_Rule.r1 AND Rule_Term.r2 {: DEBUG("AND Filter_Rule"); return new Symbol(new AndOrTerm(FilterOp.AND_TERM, r1, r2)); :}
                  | Filter_Rule.r1 OR Rule_Term.r2  {: DEBUG("OR Filter_Rule");  return new Symbol(new AndOrTerm(FilterOp.OR_TERM, r1, r2));  :}
                  ;
Rule_Term         = Rule_Term_Leaf
                  | HYPHEN Rule_Term.r {: return new Symbol(new NegTerm(r)); :}
                  | PIPE Context.cxt PIPE DOT Rule_Term.r {: return new Symbol(new ContextTerm(r, cxt)); :}
                  | LPAREN Filter_Rule.r RPAREN
						;
Filt_Or_Cat_Use_Id = Filter_Id.f                       
                     {:
									// Don't record an error
								Object o = getFilter(f, false);
								if (o == null)
									o = getCategory(f);
							   return new Symbol(o); 
							:}
                   | Collection_Id.c COLON Filter_Id.f 
						   {:
									// Record an error -- since the grammar no longer supports category collections, 
									// {c}:[f] can only refer to a filter f from a filter collection c
							   return new Symbol(getFilter(c, f, true));
							:}
						 ;
Rule_Term_Leaf    = LeafConcept.c
						  {: 
						  		DEBUG("LeafConcept"); 
								_currSym = _symbol_c; 
								return new Symbol(new LeafConcept(c, null));
						  :}
						| LeafConcept.c Min_Score.h
						  {: 
						  		DEBUG("LeafConcept"); 
								_currSym = _symbol_c; 
								return new Symbol(new LeafConcept(c, h));
						  :}
						| LeafConcept.c1 TILDE NUM_TOK.n LeafConcept.c2
						  {:  
						      DEBUG("TILDE Filter_Rule");
								return new Symbol(new ProximityTerm(c1, c2, Integer.valueOf(n)));
						  :}
						| Filt_Or_Cat_Use_Id.f
						  {: 
						  		DEBUG("Filt_Or_Cat_Use_Id"); 
								_currSym = _symbol_f; 
								if (f instanceof Filter)
									return new Symbol(new LeafFilter((Filter)f));
						      else
									return new Symbol(new LeafCategory((Category)f));
						  :}
						;
LeafConcept       = STRING_TOK.s
						  {: 
									// Convert the plain string into a concept and record it
								_cptCounter++;
						  		String name = "_cpt_" + _cptCounter;
								List kwds = new ArrayList();
								kwds.add(s);
								Concept c = new Concept(name, kwds);
								recordConcept(c);
								_globalConcepts.add(c);
								return new Symbol(c);
						  :}
                  | Cpt_Use_Id
						;
Min_Score         = COLON NUM_TOK.n {: return new Symbol(Integer.valueOf(n)); :}
						;
Context           = Cpt_Use_Id.c                   {: ArrayList l = new ArrayList(); l.add(c); return new Symbol(l); :}
                  | Context.cxt COMMA Cpt_Use_Id.c {: cxt.add(c); return _symbol_cxt; :}
                  ;
/*
Taxonomy          = DEF_TAXONOMY Ident Taxonomy_Tree END ;
*/
Taxonomy_Tree     = Tree_Nodes ;
Tree_Nodes        = Node.c {: List<Category> l = new ArrayList<Category>(); l.add(c); return new Symbol(l); :}
                  | Tree_Nodes.cl Node.c {: cl.add(c); return _symbol_cl; :}
						;
Node              = Filt_Or_Cat_Use_Id.f /* Reference to an existing filter definition */
						  {:
						     Category c = null;
							  try {
								  if (f instanceof Filter)
									  c = new Category(((Filter)f).getName(), (Filter)f);
								  else
									  c = (Category)f;
							  }
							  catch (java.lang.Exception e1) {
								  if (!(_isFirstPass && _haveUnresolvedRefs)) {
									  _log.error("Parse Error!", e1);
									  ParseUtils.parseError(_currFile, Symbol.getLine(_symbol_f.getStart()), e1.getMessage());
								  }
								     // This won't fail
								  try { c = new Category("DUMMY", new ArrayList<Category>()); } catch (java.lang.Exception e2) { }
							  }
							  if (c != f) recordCategory(c);
							  return new Symbol(c);
						  :}
                  | Filter_Decl.f   /* New filter defn */
						  {:
						     Category c = null;
							  try {
								  c = new Category(f.getName(), f);
							  }
							  catch (java.lang.Exception e1) {
								  if (!(_isFirstPass && _haveUnresolvedRefs)) {
									  _log.error("Parse Error!", e1);
									  ParseUtils.parseError(_currFile, Symbol.getLine(_symbol_f.getStart()), e1.getMessage());
								  }
								     // This won't fail
								  try { c = new Category("DUMMY", new ArrayList<Category>()); } catch (java.lang.Exception e2) { }
							  }
							  recordCategory(c);
							  return new Symbol(c);
						  :}
						| Filter_Id.f EQUAL LBRACE Taxonomy_Tree.subcats RBRACE
						  {:
						     Category c = null;
							  try {
								  c = new Category(f, subcats);
							  }
							  catch (java.lang.Exception e1) {
								  if (!(_isFirstPass && _haveUnresolvedRefs)) {
									  _log.error("Parse Error!", e1);
									  ParseUtils.parseError(_currFile, Symbol.getLine(_symbol_f.getStart()), e1.getMessage());
								  }
								     // This won't fail
								  try { c = new Category("DUMMY", subcats); } catch (java.lang.Exception e2) { }
							  }
							  recordCategory(c);
							  return new Symbol(c);
						  :}
						;
Topic             = Topic_Header.t WITH Filter_Rule.r 
                    {:
							  Issue    i = getCurrentIssue();
							  Filter   f = new Filter(i.getName(), r);	/* Create a new filter with same name as the topic! */
						     Category c = null;
							  try { 
								  c = new Category(f.getName(), f); 
							  } 
							  catch (java.lang.Exception e) { 
								     // This won't fail
								  try { c = new Category("DUMMY", r); } catch (java.lang.Exception e2) { }
							  }
							  ArrayList cats = new ArrayList();
							  cats.add(c);
						     i.addCategories(cats);
							  popScope();
							  return DUMMY_SYMBOL;
						  :}
                  | Topic_Header.t INTO_TAXONOMY Filter_Parameters? Taxonomy_Tree.cats END 
						  {:
							  Issue i = getCurrentIssue();
						     i.addCategories(cats);
							  popScope();
							  return DUMMY_SYMBOL;
						  :}
/*
  not yet supported
                  | Topic_Header.t INTO_TAXONOMY Ident {: return DEBUG("Topic w/ taxo name") :}
*/
						;
Topic_Header      = DEF_TOPIC Topic_Id.i EQUAL FILTER Source_Uses.srcs
                    {:
							  try {
								  Issue ni = new Issue(i, _user);
								  Filter.resetMinScores();
								  ni.addSources(srcs);
								  pushScope(ni);
							  }
							  catch (java.lang.Exception e) {
									// Parsing error ... No change in status
								  _log.error("Parse Error!", e);
								  ParseUtils.parseError(_currFile, e.toString());
							  }
							  return DUMMY_SYMBOL;
						  :}
                  ;
Filter_Parameters = Filter_Parameter+ ;
Filter_Parameter  = MIN_MATCH_SCORE EQUAL NUM_TOK.n {: Filter.setMinMatchScore(Integer.valueOf(n)); return DUMMY_SYMBOL; :}
                  | MIN_CONCEPT_HITS EQUAL NUM_TOK.n {: Filter.setMinConceptHitScore(Integer.valueOf(n)); return DUMMY_SYMBOL; :}
						;
Source_Uses       = Source_Use.s {: return new Symbol(processSourceUse(new HashSet<Source>(), s)); :}
						| Source_Uses.srcs COMMA Source_Use.s {: processSourceUse(srcs, s); return _symbol_srcs; :}
                  ;

/** The rules below are to support legacy issue definitions **/
Legacy_Issue_Decl = IssueStart_Decl IssueEnd_Decl.i ;
IssueStart_Decl   = DEF_TOPIC Topic_Id.i
						  {:
							  	/* Push a scope so that imports within the issue declaration
								 * are local to the issue */
							  try {
								  Issue ni = new Issue(i, _user);
						        pushScope(ni);
							  }
							  catch (java.lang.Exception e) {
									// Parsing error ... No change in status
								  _log.error("Parse Error!", e);
								  ParseUtils.parseError(_currFile, e.toString());
							  }

							  return DUMMY_SYMBOL;
						  :}
						  ;
IssueEnd_Decl     = Issue_Decl.i END 
						  {:
						     if (_log.isDebugEnabled()) DEBUG("Issue"); 
							  popScope();
							  return _symbol_i;
						  :}
                  ;
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
Import_Directives = Import_Directive+ ;
Source_Use_Decl   = MONITOR_SRCS Source_Uses.su ;
Category_Use_Decl = ORGANIZE_CATS LBRACE Taxonomy_Tree.cats RBRACE ;
