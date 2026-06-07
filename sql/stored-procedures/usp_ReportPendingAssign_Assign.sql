CREATE OR ALTER PROCEDURE dbo.usp_ReportPendingAssign_Assign
    @No_Key_D NVARCHAR(50),
    @AssignedUser NVARCHAR(100),
    @ActionUser NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRANSACTION;
    BEGIN TRY
        -- Update the assigned user and set status to '20' (In Progress/Reviewing)
        UPDATE dbo.ReportDetail
        SET AssignedUser = @AssignedUser,
            Status = '20',
            UpdateUser = @ActionUser,
            UpdateDate = GETDATE()
        WHERE No_Key_D = @No_Key_D;

        -- Record Audit Log for regulatory compliance
        INSERT INTO dbo.AuditActionLog (
            No_Key_D,
            ActionType,
            ActionUser,
            AssignedUser,
            LogDate
        ) VALUES (
            @No_Key_D,
            'ASSIGN',
            @ActionUser,
            @AssignedUser,
            GETDATE()
        );

        COMMIT TRANSACTION;
        SELECT CAST(1 AS BIT) AS IsSuccess;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT CAST(0 AS BIT) AS IsSuccess;
        THROW;
    END CATCH
END
GO
