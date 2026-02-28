import request from '@/utils/request'

export function listViolation(query) {
  return request({
    url: '/drone/violation/list',
    method: 'get',
    params: query
  })
}

export function getViolation(id) {
  return request({
    url: '/drone/violation/' + id,
    method: 'get'
  })
}

export function addViolation(data) {
  return request({
    url: '/drone/violation',
    method: 'post',
    data: data
  })
}

export function updateViolation(data) {
  return request({
    url: '/drone/violation',
    method: 'put',
    data: data
  })
}

export function delViolation(id) {
  return request({
    url: '/drone/violation/' + id,
    method: 'delete'
  })
}
