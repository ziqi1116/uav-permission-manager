package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.DroneInfo;

/**
 * 无人机信息 服务层
 */
public interface IDroneInfoService {

    DroneInfo selectDroneInfoById(Long id);

    List<DroneInfo> selectDroneInfoList(DroneInfo droneInfo);

    boolean checkSerialNumberUnique(DroneInfo droneInfo);

    int insertDroneInfo(DroneInfo droneInfo);

    int updateDroneInfo(DroneInfo droneInfo);

    int deleteDroneInfoByIds(Long[] ids);
}
