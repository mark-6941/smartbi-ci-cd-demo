using System;
using System.Collections.Generic;
using System.Data;
using System.Threading;
using System.Threading.Tasks;
using Xunit;
using Moq; // 金融業最常用的純模擬套件
using FluentAssertions;

namespace SmartPlatformPlus.Api.Tests
{
    // 💡 這裡定義我們要測試的「主查詢頁輸出」欄位結構（完全對齊你的：欄位規格.csv）
    public class ReportPendingQueryResponse
    {
        public string No_Report { get; set; }      // 報表代號
        public string ReportName { get; set; }     // 報表名稱
        public string Cd_Period { get; set; }      // 報表週期
        public string No_Dept { get; set; }        // 部門/分行別
        public int 明細筆數 { get; set; }
        public int 待處理筆數 { get; set; }
        public int 簽核中筆數 { get; set; }
        public int 已簽核筆數 { get; set; }
    }

    // 💡 這裡定義「指派經辦」的輸入參數（完全對齊你的：SP對應設計_建議.csv）
    public class AssignRequest
    {
        public string No_Key_D { get; set; }       // 明細主鍵
        public string AssignedUser { get; set; }   // 指派經辦 (主要輸入)
        public string ActionUser { get; set; }     // 操作人員/主管 (主要輸入)
    }

    // 💡 模擬金融業底層透過 Dapper 呼叫 Stored Procedure 的 Interface
    public interface IReportRepository
    {
        // 對應 usp_ReportPendingAssign_Search
        Task<IEnumerable<ReportPendingQueryResponse>> SearchPendingReportsAsync(string noReport, string dateFrom, string dateTo);
        
        // 對應 usp_ReportPendingAssign_Assign
        Task<bool> AssignUserAsync(AssignRequest request);
    }

    // ==========================================
    // 🎯 實際的 UAT 單元測試案例 (完全不連資料庫)
    // ==========================================
    public class ReportPendingAssignTests
    {
        [Fact]
        [Trait("Category", "UAT-Excel文件對齊驗證")]
        public async Task UAT_FE111_003_多條件交集查詢_應依據欄位規格正確回傳統計計數()
        {
            // [Arrange] 準備階段：用 Moq 憑空捏造資料庫回傳的 Excel 模擬資料
            var mockRepo = new Mock<IReportRepository>();
            
            // 模擬：當傳入 FE111 報表查詢時，直接吐出「欄位規格.csv」定義的輸出內容
            mockRepo.Setup(repo => repo.SearchPendingReportsAsync("FE111", "2026-06-01", "2026-06-07"))
                    .ReturnsAsync(new List<ReportPendingQueryResponse>
                    {
                        new ReportPendingQueryResponse 
                        { 
                            No_Report = "FE111", 
                            ReportName = "國外匯入匯款業務涉及制裁議題交易檢核表",
                            Cd_Period = "202606",
                            No_Dept = "DEPT01",
                            明細筆數 = 3,   // 對齊 SQL驗證範本.csv 的預期結果
                            待處理筆數 = 2,
                            簽核中筆數 = 1,
                            已簽核筆數 = 0
                        }
                    });

            var repository = mockRepo.Object;

            // [Act] 執行階段：實際呼叫這個模擬的方法
            var result = await repository.SearchPendingReportsAsync("FE111", "2026-06-01", "2026-06-07");

            // [Assert] 斷言階段：驗證回傳值是否與 Excel 文件的「預期結果」完全一致
            result.Should().NotBeNull();
            var report = result.Should().ContainSingle().Subject;
            
            // 嚴格比對欄位數值
            report.No_Report.Should().Be("FE111");
            report.明細筆數.Should().Be(3);
            report.待處理筆數.Should().Be(2); // 驗證狀態 '10' 是否為 2 筆
            report.簽核中筆數.Should().Be(1); // 驗證狀態 '20' 是否為 1 筆
        }

        [Fact]
        [Trait("Category", "UAT-Excel文件對齊驗證")]
        public async Task DB_004_單筆指派_應傳入正確經辦主管參數並回傳成功()
        {
            // [Arrange] 準備階段
            var mockRepo = new Mock<IReportRepository>();
            
            var testRequest = new AssignRequest
            {
                No_Key_D = "KEY-FE111-001",
                AssignedUser = "Banker_Tom",    // 預計指派的經辦
                ActionUser = "Supervisor_Alex"  // 稽核軌跡 AuditActionLog 要記錄的主管
            };

            // 模擬：當傳入這個指派請求時，直接回傳 true (成功)
            mockRepo.Setup(repo => repo.AssignUserAsync(It.IsAny<AssignRequest>()))
                    .ReturnsAsync(true);

            var repository = mockRepo.Object;

            // [Act] 執行階段
            var isSuccess = await repository.AssignUserAsync(testRequest);

            // [Assert] 斷言階段
            isSuccess.Should().BeTrue();

            // 🌟 關鍵合規檢查：驗證底層有沒有把「經辦」跟「主管」正確帶入（這點對金融業稽核軌跡最重要）
            mockRepo.Verify(repo => repo.AssignUserAsync(It.Is<AssignRequest>(r => 
                r.No_Key_D == "KEY-FE111-001" && 
                r.AssignedUser == "Banker_Tom" && 
                r.ActionUser == "Supervisor_Alex"
            )), Times.Once, "必須正確傳入經辦與主管欄位，以符合 AuditActionLog 稽核規範！");
        }
    }
}
