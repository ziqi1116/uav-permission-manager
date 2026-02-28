package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.FlightApplication;

/**
 * 飞行申请 服务层
 */
public interface IFlightApplicationService {

    FlightApplication selectFlightApplicationById(Long id);

    List<FlightApplication> selectFlightApplicationList(FlightApplication flightApplication);

    String generateApplicationNo();

    int insertFlightApplication(FlightApplication flightApplication);

    int updateFlightApplication(FlightApplication flightApplication);

    int deleteFlightApplicationByIds(Long[] ids);

    /**
     * 审批通过：更新申请状态、生成飞行权限、生成首条监控记录
     */
    void approve(Long applicationId, Long approveUserId, String approveRemark);

    /**
     * 审批驳回：更新申请状态并记录驳回原因
     */
    void reject(Long applicationId, Long approveUserId, String approveRemark);
}
