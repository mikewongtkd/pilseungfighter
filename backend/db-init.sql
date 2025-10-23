drop table if exists document;

create table document (
	uuid text primary key,
	class text not null,
	data text_json default '{}',
	deleted text default null,
	created text default current_timestamp,
	modified text default current_timestamp,

	/* Generated columns */
	gc_clock      text generated always as (json_extract( data, '$.clock' ))      stored,
	gc_contestant text generated always as (json_extract( data, '$.contestant' )) stored,
	gc_match      text generated always as (json_extract( data, '$.match' ))      stored,
	gc_round      text generated always as (json_extract( data, '$.round' ))      stored,
	gc_score      text generated always as (json_extract( data, '$.score' ))      stored

);

/* Indices */
drop index if exists idx_document_class;
create index idx_document_class on document (class);

/* PHP Sessions */
drop table if exists sessions;
create table sessions (
    id text primary key,
    seen int default (strftime( '%s', 'now' )),
    data text
);

