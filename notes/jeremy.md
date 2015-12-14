## JSON1 path / performance

I’m experimenting with the json1 extension, and I’d like to confirm the proper
way to detect if a key exists in the json, vs its value being null. For example:

  sqlite> select json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$.x');

  sqlite> select json_extract('{"a":2,"c":[4,5,{"f":7}]}', '$.x') IS NULL;
  1
  sqlite> select json_extract('{"x":null, "a":2,"c":[4,5,{"f":7}]}', '$.x');

  sqlite> select json_extract('{"x":null, "a":2,"c":[4,5,{"f":7}]}', '$.x') IS NULL;
  1

So far it looks as if the way to distinguish between a json key existing with a
value of null vs. not existing is to use `json_type`

  sqlite> select json_type('{"a":2,"c":[4,5,{"f":7}]}', '$.x') IS NULL;
  1
  sqlite> select json_type('{"x": null, "a":2,"c":[4,5,{"f":7}]}', '$.x');
  null

Is this correct?

Are there optimizations in place so that a column that is a json string is only
parsed once if it is involved in json1 functions? For example:

  sqlite> create table t1(doc);
  sqlite> insert into t1(doc) values(json('{"x": null, "a":2,"c":[4,5,{"f":7}]}'));
  sqlite> select json_type(doc,'$.a') IS NOT NULL, json_extract(doc, '$.a') from t1;
  1|2

In this case, is doc parsed via json twice? I'm not actually worried about
performance or anything, just wondering.

### Response from D. Richard Hipp
* yes this is the proper method to distinguish between JSON null and SQL NULL

> No. The JSON parsing turned out to be so fast that such optimizations 
> didn't seem worth the effort. Of course, things might change in the 
> future.

# FTS document id

I'm working with FTS5 and I'd like to guarantee that a particular document is
indexed only once. I have what I consider to be a document id, but it is not an
integer value its a hexadecimal string, think GUID/md5/sha1. Since the fts5
rowid column is an integer, it appears I'll need to create a mapping from my
document id to an fts5 rowid.

I'm thinking the best method for me to resolve this would to just use an
external content table with triggers to update FTS5 table. Pretty much exactly
like https://sqlite.org/fts5.html#section_4_4_2 and use triggers to keep the
FTS5 table in sync with the external content table.

If I'm going to have to use an external table to create a rowid for the
fts5 table, I might as well use use the external content table.


