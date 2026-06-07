CREATE OR ALTER PROCEDURE dbo.usp_ReportPendingAssign_Search
    @No_Report NVARCHAR(50),
    @Date_From NVARCHAR(10),
    @Date_To NVARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    -- Query report statistics by joining detail statuses
    SELECT 
        r.No_Report,
        r.ReportName,
        r.Cd_Period,
        r.No_Dept,
        COUNT(d.No_Key_D) AS 明細筆數,
        SUM(CASE WHEN d.Status = '10' THEN 1 ELSE 0 END) AS 待處理筆數,
        SUM(CASE WHEN d.Status = '20' THEN 1 ELSE 0 END) AS 簽核中筆數,
        SUM(CASE WHEN d.Status = '30' THEN 1 ELSE 0 END) AS 已簽核筆數
    FROM dbo.ReportMaster r
    LEFT JOIN dbo.ReportDetail d ON r.No_Report = d.No_Report AND r.Cd_Period = d.Cd_Period
    WHERE r.No_Report = @No_Report
      AND d.CreateDate >= @Date_From
      AND d.CreateDate <= @Date_To
    GROUP BY r.No_Report, r.ReportName, r.Cd_Period, r.No_Dept;
END
GO
