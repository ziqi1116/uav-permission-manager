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
import com.ruoyi.common.core.domain.entity.SysRole;
import com.ruoyi.system.domain.DroneInfo;
import com.ruoyi.system.service.IDroneInfoService;

/**
 * 无人机信息
 */
@RestController
@RequestMapping("/drone/droneInfo")
public class DroneInfoController extends BaseController {

    @Autowired
    private IDroneInfoService droneInfoService;

    private void applyDataScope(DroneInfo droneInfo) {
        if (SecurityUtils.isAdmin(getUserId())) return;
        List<SysRole> roles = SecurityUtils.getLoginUser().getUser().getRoles();
        if (roles == null) return;
        List<String> roleKeys = roles.stream().map(SysRole::getRoleKey).collect(java.util.stream.Collectors.toList());
        if (roleKeys.contains("drone_user") || (roleKeys.contains("flight_user") && !roleKeys.contains("approver"))) {
            droneInfo.setOwnerId(getUserId());
        }
    }

    @PreAuthorize("@ss.hasPermi('drone:droneInfo:list')")
    @GetMapping("/list")
    public TableDataInfo list(DroneInfo droneInfo) {
        applyDataScope(droneInfo);
        startPage();
        List<DroneInfo> list = droneInfoService.selectDroneInfoList(droneInfo);
        return getDataTable(list);
    }

    @Log(title = "无人机管理", businessType = BusinessType.EXPORT)
    @PreAuthorize("@ss.hasPermi('drone:droneInfo:export')")
    @PostMapping("/export")
    public void export(HttpServletResponse response, DroneInfo droneInfo) {
        applyDataScope(droneInfo);
        List<DroneInfo> list = droneInfoService.selectDroneInfoList(droneInfo);
        ExcelUtil<DroneInfo> util = new ExcelUtil<>(DroneInfo.class);
        util.exportExcel(response, list, "无人机数据");
    }

    @PreAuthorize("@ss.hasPermi('drone:droneInfo:query')")
    @GetMapping("/{id}")
    public AjaxResult getInfo(@PathVariable Long id) {
        DroneInfo drone = droneInfoService.selectDroneInfoById(id);
        if (drone == null) return error("无人机不存在");
        if (!SecurityUtils.isAdmin(getUserId()) && !getUserId().equals(drone.getOwnerId())) {
            return error("无权限查看该无人机");
        }
        return success(drone);
    }

    @PreAuthorize("@ss.hasPermi('drone:droneInfo:add')")
    @Log(title = "无人机管理", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody DroneInfo droneInfo) {
        if (!droneInfoService.checkSerialNumberUnique(droneInfo)) {
            return error("新增无人机'" + droneInfo.getDroneName() + "'失败，序列号已存在");
        }
        if (droneInfo.getOwnerId() == null && !SecurityUtils.isAdmin(getUserId())) {
            droneInfo.setOwnerId(getUserId());
        }
        droneInfo.setCreateBy(getUsername());
        return toAjax(droneInfoService.insertDroneInfo(droneInfo));
    }

    @PreAuthorize("@ss.hasPermi('drone:droneInfo:edit')")
    @Log(title = "无人机管理", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody DroneInfo droneInfo) {
        if (!SecurityUtils.isAdmin(getUserId())) {
            DroneInfo existing = droneInfoService.selectDroneInfoById(droneInfo.getId());
            if (existing == null || !getUserId().equals(existing.getOwnerId())) {
                return error("无权限修改该无人机");
            }
        }
        if (!droneInfoService.checkSerialNumberUnique(droneInfo)) {
            return error("修改无人机'" + droneInfo.getDroneName() + "'失败，序列号已存在");
        }
        droneInfo.setUpdateBy(getUsername());
        return toAjax(droneInfoService.updateDroneInfo(droneInfo));
    }

    @PreAuthorize("@ss.hasPermi('drone:droneInfo:remove')")
    @Log(title = "无人机管理", businessType = BusinessType.DELETE)
    @DeleteMapping("/{ids}")
    public AjaxResult remove(@PathVariable Long[] ids) {
        if (!SecurityUtils.isAdmin(getUserId())) {
            for (Long id : ids) {
                DroneInfo existing = droneInfoService.selectDroneInfoById(id);
                if (existing != null && !getUserId().equals(existing.getOwnerId())) {
                    return error("无权限删除部分无人机，请仅选择本人所属设备");
                }
            }
        }
        return toAjax(droneInfoService.deleteDroneInfoByIds(ids));
    }
}
