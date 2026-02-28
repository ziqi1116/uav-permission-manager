package com.ruoyi.system.mapper;

import java.util.List;
import com.ruoyi.system.domain.DroneInfo;

/**
 * 无人机信息 数据层
 */
public interface DroneInfoMapper {

    DroneInfo selectDroneInfoById(Long id);

    List<DroneInfo> selectDroneInfoList(DroneInfo droneInfo);

    DroneInfo checkSerialNumberUnique(String serialNumber);

    int insertDroneInfo(DroneInfo droneInfo);

    int updateDroneInfo(DroneInfo droneInfo);

    int deleteDroneInfoById(Long id);

    int deleteDroneInfoByIds(Long[] ids);
}
