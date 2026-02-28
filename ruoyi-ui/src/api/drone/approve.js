import request from '@/utils/request'

export function listApprove(query) {
  return request({
    url: '/drone/approve/list',
    method: 'get',
    params: query
  })
}

export function approveApplication(id, data) {
  return request({
    url: '/drone/approve/approve/' + id,
    method: 'post',
    data: data || {}
  })
}

export function rejectApplication(id, data) {
  return request({
    url: '/drone/approve/reject/' + id,
    method: 'post',
    data: data || {}
  })
}
