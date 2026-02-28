package com.ruoyi.system.service;

import java.util.List;
import com.ruoyi.system.domain.ViolationRecord;

/**
 * 违规记录 服务层
 */
public interface IViolationRecordService {

    ViolationRecord selectViolationRecordById(Long id);

    List<ViolationRecord> selectViolationRecordList(ViolationRecord violationRecord);

    int insertViolationRecord(ViolationRecord violationRecord);

    int updateViolationRecord(ViolationRecord violationRecord);

    int deleteViolationRecordByIds(Long[] ids);
}
