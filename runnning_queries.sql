select  p.spid, p.status,p.hostname,p.loginame,p.cpu,r.start_time, t.text
    from sys.dm_exec_requests as r, sys.sysprocesses p 
    cross apply sys.dm_exec_sql_text(p.sql_handle) t
    where p.status not in ('sleeping', 'background')
    and r.session_id=p.spid
