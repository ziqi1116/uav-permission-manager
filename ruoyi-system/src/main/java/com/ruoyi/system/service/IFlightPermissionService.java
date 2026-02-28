package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.FlightPermission;

/**
 * 飞行权限 服务层
 */
public interface IFlightPermissionService {

    FlightPermission selectFlightPermissionById(Long id);

    List<FlightPermission> selectFlightPermissionList(FlightPermission flightPermission);

    int insertFlightPermission(FlightPermission flightPermission);

    int updateFlightPermission(FlightPermission flightPermission);

    int deleteFlightPermissionByIds(Long[] ids);
}
