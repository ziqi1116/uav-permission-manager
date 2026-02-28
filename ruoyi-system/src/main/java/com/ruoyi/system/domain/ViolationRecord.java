package com.ruoyi.system.domain;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 违规记录表 violation_record
 */
public class ViolationRecord extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;
    /** 关联权限ID */
    @Excel(name = "权限ID")
    private Long permissionId;
    /** 违规类型 */
    @Excel(name = "违规类型")
    private String violationType;
    /** 违规描述 */
    @Excel(name = "违规描述")
    private String description;
    /** 经度（地图标记） */
    private Double longitude;
    /** 纬度（地图标记） */
    private Double latitude;
    /** 处理状态（0待处理 1已处理） */
    @Excel(name = "处理状态", readConverterExp = "0=待处理,1=已处理")
    private String handleStatus;

    /** 申请单号（关联） */
    private String applicationNo;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    @NotNull
    public Long getPermissionId() { return permissionId; }
    public void setPermissionId(Long permissionId) { this.permissionId = permissionId; }

    @NotBlank(message = "违规类型不能为空")
    @Size(max = 50)
    public String getViolationType() { return violationType; }
    public void setViolationType(String violationType) { this.violationType = violationType; }

    @Size(max = 1000)
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Double getLongitude() { return longitude; }
    public void setLongitude(Double longitude) { this.longitude = longitude; }
    public Double getLatitude() { return latitude; }
    public void setLatitude(Double latitude) { this.latitude = latitude; }

    public String getHandleStatus() { return handleStatus; }
    public void setHandleStatus(String handleStatus) { this.handleStatus = handleStatus; }

    public String getApplicationNo() { return applicationNo; }
    public void setApplicationNo(String applicationNo) { this.applicationNo = applicationNo; }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("id", id)
            .append("permissionId", permissionId)
            .append("violationType", violationType)
            .append("description", description)
            .append("handleStatus", handleStatus)
            .append("createTime", getCreateTime())
            .toString();
    }
}
