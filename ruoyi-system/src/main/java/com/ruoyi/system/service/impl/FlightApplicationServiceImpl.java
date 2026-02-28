package com.ruoyi.system.service.impl;

import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.ruoyi.common.constant.FlightConstants;
import com.ruoyi.common.exception.ServiceException;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.FlightApplication;
import com.ruoyi.system.domain.FlightMonitor;
import com.ruoyi.system.domain.FlightPermission;
import com.ruoyi.system.mapper.FlightApplicationMapper;
import com.ruoyi.system.mapper.FlightMonitorMapper;
import com.ruoyi.system.mapper.FlightPermissionMapper;
import com.ruoyi.system.service.IFlightApplicationService;

/**
 * 飞行申请 服务层实现（含审批逻辑）
 */
@Service
public class FlightApplicationServiceImpl implements IFlightApplicationService {

    @Autowired
    private FlightApplicationMapper flightApplicationMapper;
    @Autowired
    private FlightPermissionMapper flightPermissionMapper;
    @Autowired
    private FlightMonitorMapper flightMonitorMapper;

    @Override
    public FlightApplication selectFlightApplicationById(Long id) {
        return flightApplicationMapper.selectFlightApplicationById(id);
    }

    @Override
    public List<FlightApplication> selectFlightApplicationList(FlightApplication flightApplication) {
        return flightApplicationMapper.selectFlightApplicationList(flightApplication);
    }

    @Override
    public String generateApplicationNo() {
        String no = FlightConstants.APPLICATION_NO_PREFIX + System.currentTimeMillis();
        if (flightApplicationMapper.selectByApplicationNo(no) != null) {
            no = FlightConstants.APPLICATION_NO_PREFIX + System.currentTimeMillis() + (int)(Math.random() * 1000);
        }
        return no;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertFlightApplication(FlightApplication flightApplication) {
        if (StringUtils.isEmpty(flightApplication.getApplicationNo())) {
            flightApplication.setApplicationNo(generateApplicationNo());
        }
        flightApplication.setStatus(FlightConstants.APPLICATION_STATUS_PENDING);
        return flightApplicationMapper.insertFlightApplication(flightApplication);
    }

    @Override
    public int updateFlightApplication(FlightApplication flightApplication) {
        return flightApplicationMapper.updateFlightApplication(flightApplication);
    }

    @Override
    public int deleteFlightApplicationByIds(Long[] ids) {
        return flightApplicationMapper.deleteFlightApplicationByIds(ids);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void approve(Long applicationId, Long approveUserId, String approveRemark) {
        FlightApplication app = flightApplicationMapper.selectFlightApplicationById(applicationId);
        if (app == null) {
            throw new ServiceException("申请不存在");
        }
        if (!FlightConstants.APPLICATION_STATUS_PENDING.equals(app.getStatus())) {
            throw new ServiceException("当前状态不允许审批");
        }
        Date now = new Date();
        app.setStatus(FlightConstants.APPLICATION_STATUS_APPROVED);
        app.setApproveUser(approveUserId);
        app.setApproveTime(now);
        app.setApproveRemark(approveRemark != null ? approveRemark : "审批通过");
        flightApplicationMapper.updateFlightApplication(app);

        FlightPermission perm = new FlightPermission();
        perm.setApplicationId(applicationId);
        perm.setApprovedArea(app.getFlightArea());
        perm.setApprovedHeight(app.getFlightHeight() != null ? app.getFlightHeight() : 0);
        perm.setApprovedStartTime(app.getStartTime());
        perm.setApprovedEndTime(app.getEndTime());
        perm.setPermissionStatus(FlightConstants.PERMISSION_STATUS_VALID);
        flightPermissionMapper.insertFlightPermission(perm);

        FlightMonitor monitor = new FlightMonitor();
        monitor.setPermissionId(perm.getId());
        monitor.setRealTimeLocation("");
        monitor.setCurrentHeight(0);
        monitor.setWarningFlag("0");
        flightMonitorMapper.insertFlightMonitor(monitor);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void reject(Long applicationId, Long approveUserId, String approveRemark) {
        if (StringUtils.isEmpty(approveRemark)) {
            throw new ServiceException("驳回必须填写原因");
        }
        FlightApplication app = flightApplicationMapper.selectFlightApplicationById(applicationId);
        if (app == null) {
            throw new ServiceException("申请不存在");
        }
        if (!FlightConstants.APPLICATION_STATUS_PENDING.equals(app.getStatus())) {
            throw new ServiceException("当前状态不允许审批");
        }
        app.setStatus(FlightConstants.APPLICATION_STATUS_REJECTED);
        app.setApproveUser(approveUserId);
        app.setApproveTime(new Date());
        app.setApproveRemark(approveRemark);
        flightApplicationMapper.updateFlightApplication(app);
    }
}
