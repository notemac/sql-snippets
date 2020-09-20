
BEGIN
    SET XACT_ABORT ON;
    BEGIN TRY
        BEGIN TRANSACTION;
        -- some code
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) = -1
        BEGIN
            PRINT 'The transaction is in an uncommittable state.' + ' Rolling back transaction.'
            ROLLBACK TRANSACTION;
        END;
        IF (XACT_STATE()) = 1
        BEGIN
            PRINT 'The transaction is committable.' + ' Committing transaction.'
            COMMIT TRANSACTION;   
        END;
    END CATCH
END
