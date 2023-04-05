-- Placed in the public domain 20040924
--
-- Example SQLite database schema for flowinsert.pl script.
-- 
-- Create SQLite database using:
--   sqlite -init flows.sql flows.sqlite
--
-- $Id$

CREATE TABLE flows (
	tag		INTEGER,
        received	TIMESTAMP,
	agent_addr	VARCHAR(64),
	src_addr	VARCHAR(64),
	dst_addr	VARCHAR(64),
        src_port	INTEGER,
        dst_port	INTEGER,
        octets		INTEGER,
        packets		INTEGER,
        protocol	INTEGER
);

