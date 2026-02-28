package com.ruoyi.system.domain;

import java.util.Date;
import javax.validation.constraints.NotNull;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 飞行监控表 flight_monitor
 */
public class FlightMonitor extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;
    /** 关联权限ID */
    @Excel(name = "权限ID")
    private Long permissionId;
    /** 实时位置 */
    @Excel(name = "实时位置")
    private String realTimeLocation;
    /** 经度 */
    private Double longitude;
    /** 纬度 */
    private Double latitude;
    /** 当前高度(m) */
    @Excel(name = "当前高度(m)")
    private Integer currentHeight;
    /** 速度(m/s) */
    private Double speed;
    /** 告警标志（0正常 1告警） */
    @Excel(name = "告警", readConverterExp = "0=正常,1=告警")
    private String warningFlag;
    /** 飞行时间点 */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date flightTime;
    /** 是否违规（0正常 1违规） */
    private String isViolation;
    /** 创建时间（仅此表无 update） */
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date createTime;

    /** 申请单号（关联） */
    private String applicationNo;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    @NotNull
    public Long getPermissionId() { return permissionId; }
    public void setPermissionId(Long permissionId) { this.permissionId = permissionId; }

    public String getRealTimeLocation() { return realTimeLocation; }
    public void setRealTimeLocation(String realTimeLocation) { this.realTimeLocation = realTimeLocation; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public Integer getCurrentHeight() { return currentHeight != null ? currentHeight : 0; }
    public void setCurrentHeight(Integer currentHeight) { this.currentHeight = currentHeight; }

    public Double getSpeed() { return speed; }
    public void setSpeed(Double speed) { this.speed = speed; }

    public String getWarningFlag() { return warningFlag; }
    public void setWarningFlag(String warningFlag) { this.warningFlag = warningFlag; }

    public Date getFlightTime() { return flightTime; }
    public void setFlightTime(Date flightTime) { this.flightTime = flightTime; }
    public String getIsViolation() { return isViolation; }
    public void setIsViolation(String isViolation) { this.isViolation = isViolation; }

    @Override
    public Date getCreateTime() { return createTime; }
    @Override
    public void setCreateTime(Date createTime) { this.createTime = createTime; }

    public String getApplicationNo() { return applicationNo; }
    public void setApplicationNo(String applicationNo) { this.applicationNo = applicationNo; }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("id", id)
            .append("permissionId", permissionId)
            .append("realTimeLocation", realTimeLocation)
            .append("currentHeight", currentHeight)
            .append("warningFlag", warningFlag)
            .append("createTime", createTime)
            .toString();
    }
}
