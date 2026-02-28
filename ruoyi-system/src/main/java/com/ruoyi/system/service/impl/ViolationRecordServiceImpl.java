package com.ruoyi.system.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.ruoyi.system.domain.ViolationRecord;
import com.ruoyi.system.mapper.ViolationRecordMapper;
import com.ruoyi.system.service.IViolationRecordService;

@Service
public class ViolationRecordServiceImpl implements IViolationRecordService {

    @Autowired
    private ViolationRecordMapper violationRecordMapper;

    @Override
    public ViolationRecord selectViolationRecordById(Long id) {
        return violationRecordMapper.selectViolationRecordById(id);
    }

    @Override
    public List<ViolationRecord> selectViolationRecordList(ViolationRecord violationRecord) {
        return violationRecordMapper.selectViolationRecordList(violationRecord);
    }

    @Override
    public int insertViolationRecord(ViolationRecord violationRecord) {
        return violationRecordMapper.insertViolationRecord(violationRecord);
    }

    @Override
    public int updateViolationRecord(ViolationRecord violationRecord) {
        return violationRecordMapper.updateViolationRecord(violationRecord);
    }

    @Override
    public int deleteViolationRecordByIds(Long[] ids) {
        return violationRecordMapper.deleteViolationRecordByIds(ids);
    }
}
