package com.ruoyi.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.common.utils.StringUtils;
import com.ruoyi.system.domain.DroneInfo;
import com.ruoyi.system.mapper.DroneInfoMapper;
import com.ruoyi.system.service.IDroneInfoService;

/**
 * 无人机信息 服务层实现
 */
@Service
public class DroneInfoServiceImpl implements IDroneInfoService {

    @Autowired
    private DroneInfoMapper droneInfoMapper;

    @Override
    public DroneInfo selectDroneInfoById(Long id) {
        return droneInfoMapper.selectDroneInfoById(id);
    }

    @Override
    public List<DroneInfo> selectDroneInfoList(DroneInfo droneInfo) {
        return droneInfoMapper.selectDroneInfoList(droneInfo);
    }

    @Override
    public boolean checkSerialNumberUnique(DroneInfo droneInfo) {
        Long id = StringUtils.isNull(droneInfo.getId()) ? -1L : droneInfo.getId();
        DroneInfo info = droneInfoMapper.checkSerialNumberUnique(droneInfo.getSerialNumber());
        if (StringUtils.isNotNull(info) && info.getId().longValue() != id.longValue()) {
            return false;
        }
        return true;
    }

    @Override
    public int insertDroneInfo(DroneInfo droneInfo) {
        return droneInfoMapper.insertDroneInfo(droneInfo);
    }

    @Override
    public int updateDroneInfo(DroneInfo droneInfo) {
        return droneInfoMapper.updateDroneInfo(droneInfo);
    }

    @Override
    public int deleteDroneInfoByIds(Long[] ids) {
        return droneInfoMapper.deleteDroneInfoByIds(ids);
    }
}
