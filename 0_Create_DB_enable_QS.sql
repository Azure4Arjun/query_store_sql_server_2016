USE [master];
GO



CREATE DATABASE [DB1]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'DB1', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLSERVER2016RC3\MSSQL\DATA\DB1.mdf' , SIZE = 8192KB , FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'DB1_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.SQLSERVER2016RC3\MSSQL\DATA\DB1_log.ldf' , SIZE = 1024KB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [DB1] SET COMPATIBILITY_LEVEL = 130
GO
ALTER DATABASE [DB1] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [DB1] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [DB1] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [DB1] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [DB1] SET ARITHABORT OFF 
GO
ALTER DATABASE [DB1] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [DB1] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [DB1] SET AUTO_CREATE_STATISTICS ON
GO
ALTER DATABASE [DB1] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [DB1] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [DB1] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [DB1] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [DB1] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [DB1] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [DB1] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [DB1] SET  DISABLE_BROKER 
GO
ALTER DATABASE [DB1] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [DB1] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [DB1] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [DB1] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [DB1] SET  READ_WRITE 
GO
ALTER DATABASE [DB1] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [DB1] SET  MULTI_USER 
GO
ALTER DATABASE [DB1] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [DB1] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [DB1] SET DELAYED_DURABILITY = DISABLED 
GO
USE [DB1]
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
USE [DB1]
GO
IF NOT EXISTS (SELECT name FROM sys.filegroups WHERE is_default=1 AND name = N'PRIMARY') ALTER DATABASE [DB1] MODIFY FILEGROUP [PRIMARY] DEFAULT
GO


/*
ENABLE QUERY STORE
*/

USE [master];
GO


ALTER DATABASE [DB1] SET QUERY_STORE = ON
(
 OPERATION_MODE = READ_WRITE -- READ_ONLY
,CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 10)
,INTERVAL_LENGTH_MINUTES = 1
,QUERY_CAPTURE_MODE = AUTO
,DATA_FLUSH_INTERVAL_SECONDS=60
,MAX_STORAGE_SIZE_MB = 500
,SIZE_BASED_CLEANUP_MODE = AUTO
,MAX_PLANS_PER_QUERY = 1000

);
GO



/*
Detailed information on QS

*/


SELECT * FROM sys.database_query_store_options

ALTER DATABASE [DB1] SET QUERY_STORE = OFF;
GO


/*

CREATE TABLE

*/



USE DB1;
GO



CREATE TABLE T1
(
	ID INT IDENTITY(1,1) NOT NULL
	,NR INT
);
GO




INSERT INTO T1(NR)
SELECT
	number
FROM
	master..spt_values 
WHERE 
	[TYPE] = 'P'
-- (2048 row(s) affected)


-- RUN query 300x times
SELECT * FROM T1;
GO 300




CREATE CLUSTERED INDEX NX1 ON dbo.T1(ID);
GO

-- RUN query 300x times
SELECT * FROM T1;
GO 200

--- DO FORCE PLAN for Query 3 with Plan ID 2 (clustered index)



-- drop index
DROP INDEX NX1 ON dbo.t1;
GO

-- RUN query 3 x 200 times
SELECT * FROM T1;
GO 200


-- RUN query 3 x 200 times
SELECT ID FROM T1;
GO 100


SELECT NR FROM T1;
GO 100


SELECT NR, GETDATE() AS CURRENT_DATE1 FROM T1;
GO 100



/*

DROP DATABASE

-- runnable event
*/

IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DB1')
DROP DATABASE [db1];
GO


/*
Msg 3702, Level 16, State 4, Line 6
Cannot drop database "db1" because it is currently in use.
*/


use master;
GO
ALTER DATABASE [db1] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO


EXEC sp_who

EXEC sp_who2

SELECT * FROM sysprocesses