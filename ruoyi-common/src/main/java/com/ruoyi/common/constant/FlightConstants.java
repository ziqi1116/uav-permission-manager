package com.ruoyi.common.constant;

/**
 * 飞行申请/权限常量
 */
public class FlightConstants {

    /** 申请状态：待审批 */
    public static final String APPLICATION_STATUS_PENDING = "0";
    /** 申请状态：已通过 */
    public static final String APPLICATION_STATUS_APPROVED = "1";
    /** 申请状态：已驳回 */
    public static final String APPLICATION_STATUS_REJECTED = "2";

    /** 权限状态：有效 */
    public static final String PERMISSION_STATUS_VALID = "0";
    /** 权限状态：已过期 */
    public static final String PERMISSION_STATUS_EXPIRED = "1";
    /** 权限状态：已撤销 */
    public static final String PERMISSION_STATUS_REVOKED = "2";

    /** 申请单号前缀 */
    public static final String APPLICATION_NO_PREFIX = "FA";
}
