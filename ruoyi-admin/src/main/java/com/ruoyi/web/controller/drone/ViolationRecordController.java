package com.ruoyi.web.controller.drone;

import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.ruoyi.common.annotation.Log;
import com.ruoyi.common.core.controller.BaseController;
import com.ruoyi.common.core.domain.AjaxResult;
import com.ruoyi.common.core.page.TableDataInfo;
import com.ruoyi.common.enums.BusinessType;
import com.ruoyi.common.utils.SecurityUtils;
import com.ruoyi.common.utils.poi.ExcelUtil;
import com.ruoyi.system.domain.ViolationRecord;
import com.ruoyi.system.service.IViolationRecordService;

/**
 * 违规记录（普通用户无此菜单；若有权限则仅能查看与本人 permission 关联的违规）
 */
@RestController
@RequestMapping("/drone/violation")
public class ViolationRecordController extends BaseController {

    @Autowired
    private IViolationRecordService violationRecordService;

    private void applyDataScope(ViolationRecord violationRecord) {
        if (SecurityUtils.isAdmin(getUserId())) return;
        if (violationRecord.getParams() == null) violationRecord.setParams(new java.util.HashMap<>());
        violationRecord.getParams().put("applicantId", getUserId());
    }

    @PreAuthorize("@ss.hasPermi('drone:violation:list')")
    @GetMapping("/list")
    public TableDataInfo list(ViolationRecord violationRecord) {
        applyDataScope(violationRecord);
        startPage();
        List<ViolationRecord> list = violationRecordService.selectViolationRecordList(violationRecord);
        return getDataTable(list);
    }

    @Log(title = "违规记录", businessType = BusinessType.EXPORT)
    @PreAuthorize("@ss.hasPermi('drone:violation:export')")
    @PostMapping("/export")
    public void export(HttpServletResponse response, ViolationRecord violationRecord) {
        applyDataScope(violationRecord);
        List<ViolationRecord> list = violationRecordService.selectViolationRecordList(violationRecord);
        ExcelUtil<ViolationRecord> util = new ExcelUtil<>(ViolationRecord.class);
        util.exportExcel(response, list, "违规记录数据");
    }

    @PreAuthorize("@ss.hasPermi('drone:violation:query')")
    @GetMapping("/{id}")
    public AjaxResult getInfo(@PathVariable Long id) {
        return success(violationRecordService.selectViolationRecordById(id));
    }

    @PreAuthorize("@ss.hasPermi('drone:violation:add')")
    @Log(title = "违规记录", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody ViolationRecord violationRecord) {
        violationRecord.setCreateBy(getUsername());
        return toAjax(violationRecordService.insertViolationRecord(violationRecord));
    }

    @PreAuthorize("@ss.hasPermi('drone:violation:edit')")
    @Log(title = "违规记录", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody ViolationRecord violationRecord) {
        violationRecord.setUpdateBy(getUsername());
        return toAjax(violationRecordService.updateViolationRecord(violationRecord));
    }

    @PreAuthorize("@ss.hasPermi('drone:violation:remove')")
    @Log(title = "违规记录", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids) {
        return toAjax(violationRecordService.deleteViolationRecordByIds(ids));
    }
}
