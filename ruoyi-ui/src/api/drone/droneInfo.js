import request from '@/utils/request'

export function listDroneInfo(query) {
  return request({
    url: '/drone/droneInfo/list',
    method: 'get',
    params: query
  })
}

export function getDroneInfo(id) {
  return request({
    url: '/drone/droneInfo/' + id,
    method: 'get'
  })
}

export function addDroneInfo(data) {
  return request({
    url: '/drone/droneInfo',
    method: 'post',
    data: data
  })
}

export function updateDroneInfo(data) {
  return request({
    url: '/drone/droneInfo',
    method: 'put',
    data: data
  })
}

export function delDroneInfo(id) {
  return request({
    url: '/drone/droneInfo/' + id,
    method: 'delete'
  })
}
