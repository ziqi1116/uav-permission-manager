package com.ruoyi.system.domain;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import org.apache.commons.lang3.builder.ToStringBuilder;
import org.apache.commons.lang3.builder.ToStringStyle;
import com.ruoyi.common.annotation.Excel;
import com.ruoyi.common.core.domain.BaseEntity;

/**
 * 无人机信息表 drone_info
 */
public class DroneInfo extends BaseEntity {

    private static final long serialVersionUID = 1L;

    /** 主键ID */
    private Long id;
    /** 无人机名称 */
    @Excel(name = "无人机名称")
    private String droneName;
    /** 机型型号 */
    @Excel(name = "机型型号")
    private String droneModel;
    /** 序列号 */
    @Excel(name = "序列号")
    private String serialNumber;
    /** 所属用户ID */
    @Excel(name = "所属用户ID")
    private Long ownerId;
    /** 状态（0正常 1停用） */
    @Excel(name = "状态", readConverterExp = "0=正常,1=停用")
    private String status;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    @NotBlank(message = "无人机名称不能为空")
    @Size(min = 1, max = 100)
    public String getDroneName() { return droneName; }
    public void setDroneName(String droneName) { this.droneName = droneName; }

    @Size(max = 100)
    public String getDroneModel() { return droneModel; }
    public void setDroneModel(String droneModel) { this.droneModel = droneModel; }

    @NotBlank(message = "序列号不能为空")
    @Size(min = 1, max = 100)
    public String getSerialNumber() { return serialNumber; }
    public void setSerialNumber(String serialNumber) { this.serialNumber = serialNumber; }

    public Long getOwnerId() { return ownerId; }
    public void setOwnerId(Long ownerId) { this.ownerId = ownerId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    @Override
    public String toString() {
        return new ToStringBuilder(this, ToStringStyle.MULTI_LINE_STYLE)
            .append("id", id)
            .append("droneName", droneName)
            .append("droneModel", droneModel)
            .append("serialNumber", serialNumber)
            .append("ownerId", ownerId)
            .append("status", status)
            .append("createBy", getCreateBy())
            .append("createTime", getCreateTime())
            .append("updateBy", getUpdateBy())
            .append("updateTime", getUpdateTime())
            .append("remark", getRemark())
            .toString();
    }
}
