USE [YelpReviews]
GO

ALTER TABLE Business 
ALTER COLUMN business_id varchar(100) NOT NULL
GO

CREATE UNIQUE NONCLUSTERED INDEX [UK_BusinessId] ON [dbo].[Business]
(
	[business_id] ASC
)
GO

CREATE FULLTEXT CATALOG [YelpFT]
WITH ACCENT_SENSITIVITY = ON
GO

CREATE FULLTEXT INDEX ON [dbo].[Business]
    ([attributes] LANGUAGE 'English', [business_address] LANGUAGE 'English', [business_hours] LANGUAGE 'English', [business_name] LANGUAGE 'English', [categories] LANGUAGE 'English', [neighborhood] LANGUAGE 'English')
    KEY INDEX [UK_BusinessId]
    ON ([YelpFT], FILEGROUP [PRIMARY])
    WITH CHANGE_TRACKING AUTO, STOPLIST SYSTEM;
GO

-- Check to see if the Index population has completed
SELECT *
FROM   sys.dm_fts_index_population
WHERE  database_id = db_id('YelpReviews')
       AND table_id = object_id('Business');
GO

-- Sample query on address
-- Use the estimated execution plan to illustrate the fact that the fulltext index is being used
SELECT * FROM Business
-- WHERE business_address LIKE '%Major Mackenzie Drive%'
where CONTAINS (business_address, 'Major AND Mackenzie AND Drive')
GO

-- Look at another column using FTS, this time use PF Changs
-- This is spelt as PF Changs sometimes but mostly P.F. Chang's
-- It is interesting to know that FTS will behave ("correctly", from a human point of view) 
-- retrieve all the occurences of P.F. Chang's also.
SELECT * FROM Business
-- WHERE business_name LIKE '%PF Chang%'
where CONTAINS (business_name, 'PF AND Chang''s')
GO
