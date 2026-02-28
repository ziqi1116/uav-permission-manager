import request from '@/utils/request'

export function listMonitor(query) {
  return request({
    url: '/drone/monitor/list',
    method: 'get',
    params: query
  })
}

export function getMonitor(id) {
  return request({
    url: '/drone/monitor/' + id,
    method: 'get'
  })
}

export function addMonitor(data) {
  return request({
    url: '/drone/monitor',
    method: 'post',
    data: data
  })
}

export function updateMonitor(data) {
  return request({
    url: '/drone/monitor',
    method: 'put',
    data: data
  })
}

export function delMonitor(id) {
  return request({
    url: '/drone/monitor/' + id,
    method: 'delete'
  })
}

/** 当前飞行任务（地图用） */
export function getCurrentTasks() {
  return request({
    url: '/drone/monitor/currentTasks',
    method: 'get'
  })
}

/** 某权限轨迹点（地图折线） */
export function getTrajectory(permissionId) {
  return request({
    url: '/drone/monitor/trajectory/' + permissionId,
    method: 'get'
  })
}

/** 分页：飞行任务列表（多任务轨迹监控） */
export function getTaskList(query) {
  return request({
    url: '/drone/monitor/task/list',
    method: 'get',
    params: query
  })
}

/** 某权限轨迹（longitude, latitude, speed, flightTime, isViolation），支持分页 */
export function getTrack(permissionId, params) {
  return request({
    url: '/drone/monitor/track/' + permissionId,
    method: 'get',
    params: params || {}
  })
}

/** 某权限违规点（地图红色 marker） */
export function getViolationPoints(permissionId) {
  return request({
    url: '/drone/monitor/violation/' + permissionId,
    method: 'get'
  })
}
