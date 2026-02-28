package com.ruoyi.system.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.FlightPermission;

/**
 * 飞行权限 数据层
 */
public interface FlightPermissionMapper {

    /** 根据权限ID查询申请人ID（用于数据权限校验） */
    Long selectApplicantIdByPermissionId(@Param("permissionId") Long permissionId);

    FlightPermission selectFlightPermissionById(Long id);

    List<FlightPermission> selectFlightPermissionList(FlightPermission flightPermission);

    FlightPermission selectByApplicationId(Long applicationId);

    int insertFlightPermission(FlightPermission flightPermission);

    int updateFlightPermission(FlightPermission flightPermission);

    int deleteFlightPermissionById(Long id);

    int deleteFlightPermissionByIds(Long[] ids);
}
