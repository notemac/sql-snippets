
-- Enable the Common Language Runtime (CLR) integration feature
exec sp_configure 'clr enabled', 1; 
reconfigure;

drop assembly Moex

EXEC sp_configure 'show advanced options', 1
reconfigure;
EXEC sp_configure 'clr strict security', 1;
RECONFIGURE;

-- Add an assembly to the list of trusted assemblies for the server (to sys.trusted_assemblies)
exec sp_add_trusted_assembly

CREATE ASSEMBLY Moex
from 'D:\repos\csharp\ConsoleApp2\bin\Release\MoexSecurities.dll'
WITH PERMISSION_SET = SAFE; --CLR assembly  created withmay be able to access external system resources, call unmanaged code, and acquire sysadmin privileges



ALTER DATABASE tabular_experimental
        SET TRUSTWORTHY ON;
ALTER DATABASE tabular_experimental
        SET TRUSTWORTHY OFF;
--ALTER ASSEMBLY ConsoleApp2
   --WITH PERMISSION_SET = UNSAFE;

CREATE PROCEDURE MoexTest 
as 
EXTERNAL NAME Moex.[MoexSecurities.Program].Main; 


begin try
declare @ret int;
exec @ret = dbo.MoexTest
select @ret
end try
begin catch
	declare
		@ОшибкаОписание varchar(512) = error_message()
		,@ОшибкаСтрока   smallint     = error_line();
    select @ОшибкаОписание
    print 'sdfsdfsdfsdfsdf'
	--throw;
end catch

EXEC sp_configure 'clr strict security', 1;
RECONFIGURE;

ALTER DATABASE tabular_experimental
        SET TRUSTWORTHY OFF;

        
select * from sys.dm_clr_properties;
select * from sys.assemblies
select * from sys.assembly_files
select * from sys.assembly_references
select * from sys.assembly_modules
select * from sys.configurations
