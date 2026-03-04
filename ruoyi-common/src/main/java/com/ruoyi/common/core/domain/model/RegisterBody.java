package com.ruoyi.common.core.domain.model;

/**
 * 用户注册对象
 *
 * 增加昵称字段，便于前端在注册时单独填写昵称。
 *
 * @author ruoyi
 */
public class RegisterBody extends LoginBody
{
    /**
     * 用户昵称
     */
    private String nickName;

    public String getNickName()
    {
        return nickName;
    }

    public void setNickName(String nickName)
    {
        this.nickName = nickName;
    }
}
