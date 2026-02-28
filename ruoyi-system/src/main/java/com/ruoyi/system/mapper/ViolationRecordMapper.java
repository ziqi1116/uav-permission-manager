package com.ruoyi.system.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Param;
import com.ruoyi.system.domain.ViolationRecord;

/**
 * 违规记录 数据层
 */
public interface ViolationRecordMapper {

    ViolationRecord selectViolationRecordById(Long id);

    List<ViolationRecord> selectViolationRecordList(ViolationRecord violationRecord);

    int insertViolationRecord(ViolationRecord violationRecord);

    int updateViolationRecord(ViolationRecord violationRecord);

    int deleteViolationRecordById(Long id);

    int deleteViolationRecordByIds(Long[] ids);

    /** 某权限的违规点列表（地图标记） */
    List<Map<String, Object>> selectViolationPointsByPermissionId(@Param("permissionId") Long permissionId);
}
