use master;
set nocount on;
go
exec sp_configure 'show advanced options', 1;
reconfigure;
-- Enable the Common Language Runtime (CLR) integration feature
exec sp_configure 'clr enabled', 1; 
reconfigure;
