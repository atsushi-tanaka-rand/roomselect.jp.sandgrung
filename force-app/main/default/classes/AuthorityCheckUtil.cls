public class AuthorityCheckUtil {

    /** 利用者権限 */
    private static final Boolean USEAUTHORITY_CONTRACTMANAGEMENT       = SystemConfig__c.getInstance().UseAuthority_ContractManagement__c;        // 利用権限_契約管理
    private static final Boolean USEAUTHORITY_PORTAL                   = SystemConfig__c.getInstance().UseAuthority_Portal__c;                    // 利用権限_自社HP
    private static final Boolean USEAUTHORITY_FLOORPLANAUTOMATION      = SystemConfig__c.getInstance().UseAuthority_FloorPlanAutomation__c;       // 利用権限_間取り図自動化
    private static final Boolean USEAUTHORITY_HOUSINGSECURITYMUTUALAID = SystemConfig__c.getInstance().UseAuthority_HousingSecurityMutualAid__c;  // 利用権限_住宅保障共済会連携 
    private static final Boolean USEAUTHORITY_PANORAMATOUR             = SystemConfig__c.getInstance().UseAuthority_PanoramaTour__c;              // 利用権限_パノラマツアー

    /**
     * 権限確認　契約管理
     * @param  Boolean    exceptionIssuanceFlags   例外発行フラグ（True：利用権限が無ければビジネスロジックException発行
     *                                                            False：利用権限が無ければ戻り値をFalseで返す）
     * @return Boolean                             利用権限チェック結果（True：利用権限有、False：利用権限無）
     */
    public static Boolean getAuthorityOptionContractManagement(Boolean exceptionIssuanceFlags){
        // 利用権限_契約管理チェック
        if(USEAUTHORITY_CONTRACTMANAGEMENT){
            // 利用権限有
            return true;
        }

        // 例外発行フラグ
        if (exceptionIssuanceFlags){
            // 例外発行フラグ有ならビジネスロジックException発行
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_SYSTEM_USEAUTHORITY, '契約管理機能の利用権限'));
            throw ex;
        }

        // 権限がなく例外エラーを発生しない場合、Falseで返す。
        return false;
    }

    /**
     * 権限確認　自社ポータルサイト
     * @param  Boolean    exceptionIssuanceFlags   例外発行フラグ（True：利用権限が無ければビジネスロジックException発行
     *                                                            False：利用権限が無ければ戻り値をFalseで返す）
     * @return Boolean                             利用権限チェック結果（True：利用権限有、False：利用権限無）
     */
    public static Boolean getAuthorityOptionPortal(Boolean exceptionIssuanceFlags){
        // 利用権限_自社HPチェック
        if(USEAUTHORITY_PORTAL){
            // 利用権限有
            return true;
        }

        // 例外発行フラグ
        if (exceptionIssuanceFlags){
            // 例外発行フラグ有ならビジネスロジックException発行
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_SYSTEM_USEAUTHORITY, 'ポータルサイトのご契約'));
            throw ex;
        }

        // 権限がなく例外エラーを発生しない場合、Falseで返す。
        return false;
    }

    /**
     * 権限確認　間取り図自動化
     * @param  Boolean    exceptionIssuanceFlags   例外発行フラグ（True：利用権限が無ければビジネスロジックException発行
     *                                                            False：利用権限が無ければ戻り値をFalseで返す）
     * @return Boolean                             利用権限チェック結果（True：利用権限有、False：利用権限無）
     */
    public static Boolean getAuthorityOptionFloorPlanAutomation(Boolean exceptionIssuanceFlags){
        // 利用権限_間取り図自動化チェック
        if(USEAUTHORITY_FLOORPLANAUTOMATION){
            // 利用権限有
            return true;
        }

        // 例外発行フラグ
        if (exceptionIssuanceFlags){
            // 例外発行フラグ有ならビジネスロジックException発行
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_SYSTEM_USEAUTHORITY, '間取り図自動取込機能の利用権限'));
            throw ex;
        }

        // 権限がなく例外エラーを発生しない場合、Falseで返す。
        return false;
    }

    /**
     * 権限確認　住宅保障共済会連携
     * @param  Boolean    exceptionIssuanceFlags   例外発行フラグ（True：利用権限が無ければビジネスロジックException発行
     *                                                            False：利用権限が無ければ戻り値をFalseで返す）
     * @return Boolean                             利用権限チェック結果（True：利用権限有、False：利用権限無）
     */
    public static Boolean getAuthorityOptionHousingSecurityMutualAid(Boolean exceptionIssuanceFlags){
        // 利用権限_住宅保障共済会連携チェック
        if(USEAUTHORITY_HOUSINGSECURITYMUTUALAID){
            // 利用権限有
            return true;
        }

        // 例外発行フラグ
        if (exceptionIssuanceFlags){
            // 例外発行フラグ有ならビジネスロジックException発行
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_SYSTEM_USEAUTHORITY, '住宅保障共済会連携機能の利用権限'));
            throw ex;
        }

        // 権限がなく例外エラーを発生しない場合、Falseで返す。
        return false;
    }

    /**
     * 権限確認　パノラマツアー
     * @param  Boolean    exceptionIssuanceFlags   例外発行フラグ（True：利用権限が無ければビジネスロジックException発行
     *                                                            False：利用権限が無ければ戻り値をFalseで返す）
     * @return Boolean                             利用権限チェック結果（True：利用権限有、False：利用権限無）
     */
    public static Boolean getAuthorityOptionPanoramaTour(Boolean exceptionIssuanceFlags){
        // 利用権限_パノラマツアーチェック
        if(USEAUTHORITY_PANORAMATOUR){
            // 利用権限有
            return true;
        }

        // 例外発行フラグ
        if (exceptionIssuanceFlags){
            // 例外発行フラグ有ならビジネスロジックException発行
            BusinessLogicException ex = new BusinessLogicException();
            ex.addMessage(CommonUtil.callMessageCreate(CommonConst_ptl.MSG_COM_E_SYSTEM_USEAUTHORITY, 'パノラマツアーの利用権限'));
            throw ex;
        }

        // 権限がなく例外エラーを発生しない場合、Falseで返す。
        return false;
    }

}