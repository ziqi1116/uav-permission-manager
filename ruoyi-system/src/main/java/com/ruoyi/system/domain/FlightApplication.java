package com.ruoyi.system.domain;

import java.util.Date;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 飞行申请表 flight_application
 */
public class FlightApplication extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;
    /** 申请单号 */
    @Excel(name = "申请单号")
    private String applicationNo;
    /** 申请人ID */
    @Excel(name = "申请人ID")
    private Long applicantId;
    /** 无人机ID */
    @Excel(name = "无人机ID")
    private Long droneId;
    /** 飞行区域 */
    @Excel(name = "飞行区域")
    private String flightArea;
    /** 申请飞行高度(m) */
    @Excel(name = "申请飞行高度(m)")
    private Integer flightHeight;
    /** 计划开始时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "计划开始时间", dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date startTime;
    /** 计划结束时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    @Excel(name = "计划结束时间", dateFormat = "yyyy-MM-dd HH:mm:ss")
    private Date endTime;
    /** 飞行目的 */
    @Excel(name = "飞行目的")
    private String purpose;
    /** 状态（0待审批 1已通过 2已驳回） */
    @Excel(name = "状态", readConverterExp = "0=待审批,1=已通过,2=已驳回")
    private String status;
    /** 审批人ID */
    private Long approveUser;
    /** 审批时间 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date approveTime;
    /** 审批意见/驳回原因 */
    private String approveRemark;
    /** 二次审批人（预留） */
    private Long secondApproveUser;
    /** 二次审批时间（预留） */
    private Date secondApproveTime;

    /** 申请人姓名（关联查询） */
    private String applicantName;
    /** 无人机名称（关联查询） */
    private String droneName;
    /** 审批人姓名（关联查询） */
    private String approveUserName;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getApplicationNo() { return applicationNo; }
    public void setApplicationNo(String applicationNo) { this.applicationNo = applicationNo; }

    @NotNull(message = "申请人不能为空")
    public Long getApplicantId() { return applicantId; }
    public void setApplicantId(Long applicantId) { this.applicantId = applicantId; }

    @NotNull(message = "无人机不能为空")
    public Long getDroneId() { return droneId; }
    public void setDroneId(Long droneId) { this.droneId = droneId; }

    @NotBlank(message = "飞行区域不能为空")
    @Size(max = 500)
    public String getFlightArea() { return flightArea; }
    public void setFlightArea(String flightArea) { this.flightArea = flightArea; }

    public Integer getFlightHeight() { return flightHeight != null ? flightHeight : 0; }
    public void setFlightHeight(Integer flightHeight) { this.flightHeight = flightHeight; }

    @NotNull(message = "计划开始时间不能为空")
    public Date getStartTime() { return startTime; }
    public void setStartTime(Date startTime) { this.startTime = startTime; }

    @NotNull(message = "计划结束时间不能为空")
    public Date getEndTime() { return endTime; }
    public void setEndTime(Date endTime) { this.endTime = endTime; }

    @Size(max = 500)
    public String getPurpose() { return purpose; }
    public void setPurpose(String purpose) { this.purpose = purpose; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Long getApproveUser() { return approveUser; }
    public void setApproveUser(Long approveUser) { this.approveUser = approveUser; }

    public Date getApproveTime() { return approveTime; }
    public void setApproveTime(Date approveTime) { this.approveTime = approveTime; }

    public String getApproveRemark() { return approveRemark; }
    public void setApproveRemark(String approveRemark) { this.approveRemark = approveRemark; }

    public Long getSecondApproveUser() { return secondApproveUser; }
    public void setSecondApproveUser(Long secondApproveUser) { this.secondApproveUser = secondApproveUser; }

    public Date getSecondApproveTime() { return secondApproveTime; }
    public void setSecondApproveTime(Date secondApproveTime) { this.secondApproveTime = secondApproveTime; }

    public String getApplicantName() { return applicantName; }
    public void setApplicantName(String applicantName) { this.applicantName = applicantName; }

    public String getDroneName() { return droneName; }
    public void setDroneName(String droneName) { this.droneName = droneName; }

    public String getApproveUserName() { return approveUserName; }
    public void setApproveUserName(String approveUserName) { this.approveUserName = approveUserName; }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("id", id)
            .append("applicationNo", applicationNo)
            .append("applicantId", applicantId)
            .append("droneId", droneId)
            .append("flightArea", flightArea)
            .append("flightHeight", flightHeight)
            .append("startTime", startTime)
            .append("endTime", endTime)
            .append("purpose", purpose)
            .append("status", status)
            .append("approveUser", approveUser)
            .append("approveTime", approveTime)
            .append("approveRemark", approveRemark)
            .append("createTime", getCreateTime())
            .toString();
    }
}
