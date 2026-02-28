import request from '@/utils/request'

export function listApplication(query) {
  return request({
    url: '/drone/application/list',
    method: 'get',
    params: query
  })
}

export function getApplication(id) {
  return request({
    url: '/drone/application/' + id,
    method: 'get'
  })
}

export function addApplication(data) {
  return request({
    url: '/drone/application',
    method: 'post',
    data: data
  })
}

export function updateApplication(data) {
  return request({
    url: '/drone/application',
    method: 'put',
    data: data
  })
}

export function delApplication(id) {
  return request({
    url: '/drone/application/' + id,
    method: 'delete'
  })
}

export function genApplicationNo() {
  return request({
    url: '/drone/application/genApplicationNo',
    method: 'get'
  })
}
