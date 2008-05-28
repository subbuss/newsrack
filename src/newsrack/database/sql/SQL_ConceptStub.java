package newsrack.database.sql;

import java.util.Iterator;
import java.util.Arrays;

import newsrack.filter.Concept;
import newsrack.filter.ConceptToken;

public class SQL_ConceptStub extends Concept
{
	public SQL_ConceptStub(Long key, String name, String defnString, String token)
	{
		super(name, defnString);
		setKey(key);
		setLexerToken(new ConceptToken(token));
	}

	public Iterator getKeywords() {
		try {
			return super.getKeywords();
		}
		catch (NullPointerException e) {
			String keywords = (String)SQL_StmtExecutor.execute(
										"SELECT keywords FROM concept_table WHERE cpt_key = ?",
										SQL_StmtType.QUERY,
										new Object[]{getKey()},
										new SQL_ValType[]{SQL_ValType.LONG},
										null,
										new GetStringResultProcessor(),
										true);
			super.setKeywords(Arrays.asList(keywords.split("\n")));
			return super.getKeywords();
		}
	}
}
