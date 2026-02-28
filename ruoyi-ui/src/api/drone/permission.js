import request from '@/utils/request'

export function listPermission(query) {
  return request({
    url: '/drone/permission/list',
    method: 'get',
    params: query
  })
}

export function getPermission(id) {
  return request({
    url: '/drone/permission/' + id,
    method: 'get'
  })
}
