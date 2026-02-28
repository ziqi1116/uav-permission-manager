import request from '@/utils/request'

export function getStatisticsAll(beginTime, endTime) {
  return request({
    url: '/drone/statistics/all',
    method: 'get',
    params: { beginTime, endTime }
  })
}

export function getApplicationCount(beginTime, endTime) {
  return request({
    url: '/drone/statistics/applicationCount',
    method: 'get',
    params: { beginTime, endTime }
  })
}

export function getAreaUsage() {
  return request({
    url: '/drone/statistics/areaUsage',
    method: 'get'
  })
}

export function getViolationCount(beginTime, endTime) {
  return request({
    url: '/drone/statistics/violationCount',
    method: 'get',
    params: { beginTime, endTime }
  })
}

/** 首页大屏：4 卡片 + 申请趋势 + 空域占比 + 违规趋势 */
export function getDashboard(beginTime, endTime) {
  return request({
    url: '/drone/statistics/dashboard',
    method: 'get',
    params: { beginTime, endTime }
  })
}
