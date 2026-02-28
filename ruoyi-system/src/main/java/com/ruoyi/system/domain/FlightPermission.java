package com.ruoyi.system.domain;

import java.util.Date;
import javax.validation.constraints.NotNull;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 飞行权限表 flight_permission
 */
public class FlightPermission extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;
    /** 关联申请ID */
    @Excel(name = "申请ID")
    private Long applicationId;
    /** 批准飞行区域 */
    @Excel(name = "批准区域")
    private String approvedArea;
    /** 批准飞行高度(m) */
    @Excel(name = "批准高度(m)")
    private Integer approvedHeight;
    /** 批准开始时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "批准开始时间", dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date approvedStartTime;
    /** 批准结束时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "批准结束时间", dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date approvedEndTime;
    /** 权限状态（0有效 1已过期 2已撤销） */
    @Excel(name = "权限状态", readConverterExp = "0=有效,1=已过期,2=已撤销")
    private String permissionStatus;

    /** 申请单号（关联） */
    private String applicationNo;
    /** 申请人ID（关联） */
    private Long applicantId;
    /** 申请人姓名（关联） */
    private String applicantName;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    @NotNull
    public Long getApplicationId() { return applicationId; }
    public void setApplicationId(Long applicationId) { this.applicationId = applicationId; }

    public String getApprovedArea() { return approvedArea; }
    public void setApprovedArea(String approvedArea) { this.approvedArea = approvedArea; }

    public Integer getApprovedHeight() { return approvedHeight != null ? approvedHeight : 0; }
    public void setApprovedHeight(Integer approvedHeight) { this.approvedHeight = approvedHeight; }

    public Date getApprovedStartTime() { return approvedStartTime; }
    public void setApprovedStartTime(Date approvedStartTime) { this.approvedStartTime = approvedStartTime; }

    public Date getApprovedEndTime() { return approvedEndTime; }
    public void setApprovedEndTime(Date approvedEndTime) { this.approvedEndTime = approvedEndTime; }

    public String getPermissionStatus() { return permissionStatus; }
    public void setPermissionStatus(String permissionStatus) { this.permissionStatus = permissionStatus; }

    public String getApplicationNo() { return applicationNo; }
    public void setApplicationNo(String applicationNo) { this.applicationNo = applicationNo; }

    public Long getApplicantId() { return applicantId; }
    public void setApplicantId(Long applicantId) { this.applicantId = applicantId; }

    public String getApplicantName() { return applicantName; }
    public void setApplicantName(String applicantName) { this.applicantName = applicantName; }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("id", id)
            .append("applicationId", applicationId)
            .append("approvedArea", approvedArea)
            .append("approvedHeight", approvedHeight)
            .append("approvedStartTime", approvedStartTime)
            .append("approvedEndTime", approvedEndTime)
            .append("permissionStatus", permissionStatus)
            .append("createTime", getCreateTime())
            .toString();
    }
}
