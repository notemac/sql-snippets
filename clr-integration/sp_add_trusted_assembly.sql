/*
Created By: 
Created On: 2020-06-04
Updated On: 2020-06-04
Description: This script shows a technique for handling SQLCLR Assemblies, marked as SAFE/EXTERNAL_ACCESS/UNSAFE/ 
             and not signed, for SQL Server version from SQL2017 while both keeping "clr strict security" enabled
             and "TRUSTWORTHY" disabled.
TODO: дописать скрипт
*/

use master;
set nocount on;
go
/* The SHA512 hash value of the assembly MoexSecurities.dll. 
   How to get sha512 hash value: certutil -hashfile D:\MoexSecurities.dll sha512 */
declare @assemblyHash varbinary(4000) = 0xc299f4ca70268723f86e0f02ff8028a279f44fbf7c488b0e6a85d227b64dac0197958354e5b21d8b7e1e126fbe5b5498c378470b8041f193cb92ed3122bbff82;
-- How to get an assembly public token: sn -Tp D:\MoexSecurities.dll
declare @assemblyDescription nvarchar(4000) = N'MoexSecurities, version=1.0.0.0, culture=neutral, publickeytoken=2686767ef2f3d556 , processorarchitecture=msil';
declare @serverVersion int =
(
    select
      case 
         when convert(nvarchar(128), serverproperty('ProductVersion')) like N'8%' then 2000
         when convert(nvarchar(128), serverproperty('ProductVersion')) like N'9%' then 2005
         when convert(nvarchar(128), serverproperty('ProductVersion')) like N'10%' then 2008
         when convert(nvarchar(128), serverproperty('ProductVersion')) like N'11%' then 2012
         when convert(nvarchar(128), serverproperty('ProductVersion')) like N'12%' then 2014
         when convert(nvarchar(128), serverproperty('ProductVersion')) like N'13%' then 2016
         when convert(nvarchar(128), serverproperty('ProductVersion')) like N'14%' then 2017
         when convert(nvarchar(128), serverproperty('ProductVersion')) like N'15%' then 2019
         else -1
      end
);

if @serverVersion >= 2017
begin
    /*
    print 'Enabling showing configuration advanced options for SQL Server Instance...'
    exec sp_configure 'show advanced options', 1;
    reconfigure; 
    --*/
    print 'Enabling SQL Server CLR Integration...';
    exec sp_configure 'clr enabled', 1; 
    reconfigure;
    /* Add an assembly to the list of trusted assemblies for the server (to sys.trusted_assemblies)
       Drop an assembly from the list of trusted assemblies: exec sp_drop_trusted_assembly @hash */
    print 'Adding an assembly to the list of trusted assemblies for the server...';
    exec sp_add_trusted_assembly @assemblyHash, @assemblyDescription
end;

-- 

CREATE ASSEMBLY MoexSecurities
from 'C:\Users\notem\Desktop\MoexSecurities\MoexSecurities\bin\Release\MoexSecurities.dll'
WITH PERMISSION_SET = EXTERNAL_ACCESS;



drop PROCEDURE MoexTest 
/* -- Drop an assembly
drop assembly MoexSecurities;
declare @assemblyHash varbinary(4000) = 0xc299f4ca70268723f86e0f02ff8028a279f44fbf7c488b0e6a85d227b64dac0197958354e5b21d8b7e1e126fbe5b5498c378470b8041f193cb92ed3122bbff82;
exec sp_drop_trusted_assembly @assemblyHash
--*/
